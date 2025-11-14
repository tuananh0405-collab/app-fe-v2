package com.example.flutter_application_1.faceid.data.service;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;

import lombok.Getter;
import lombok.Setter;
import retrofit2.Call;
import com.example.flutter_application_1.faceid.data.api.FaceIdApiController;
import com.example.flutter_application_1.faceid.data.model.response.FaceIdRequestStatusResponse;
import com.example.flutter_application_1.auth.client.ApiClient;

/**
 * Manager để quản lý Face ID request lifecycle
 * - Status polling
 * - Retry logic với exponential backoff
 * - Timeout handling
 * - Request cleanup
 */
public class FaceIdRequestManager {
    private static final String TAG = "FaceIdRequestManager";
    
    // Request lifecycle states
    public enum RequestState {
        PENDING,        // Request đang chờ verification
        VERIFIED,       // Đã verify thành công
        EXPIRED,        // Request đã hết hạn
        CANCELLED,      // Request đã bị hủy
        FAILED          // Verification thất bại
    }
    
    // Configuration
    private static final int STATUS_POLL_INTERVAL_MS = 2000; // 2 giây
    
    // Dependencies
    private final Context context;
    private final FaceIdApiController apiController;
    private final ScheduledExecutorService scheduler;
    private final Handler mainHandler;

    // Getters
    // Request state
    @Getter
    private String currentRequestId;
    private String currentSessionId;
    private RequestState currentState;
    private long expirationTime;
    private int retryCount = 0;
    private long lastRetryTime = 0;

    // Callbacks
    @Setter
    private RequestStatusCallback statusCallback;
    @Setter
    private RequestExpiredCallback expiredCallback;
    
    // Polling
    private boolean isPolling = false;
    private Runnable statusPollingRunnable;
    private ScheduledFuture<?> statusPollingFuture;
    
    public interface RequestStatusCallback {
        void onRequestStatusUpdated(RequestState state, FaceIdRequestStatusResponse response);
        void onRequestExpired();
        void onRequestCancelled();
        void onRequestFailed(String error);
    }
    
    public interface RequestExpiredCallback {
        void onExpired();
    }
    
    public FaceIdRequestManager(Context context) {
        this.context = context;
        this.apiController = ApiClient.getClient(context).create(FaceIdApiController.class);
        this.scheduler = Executors.newScheduledThreadPool(2);
        this.mainHandler = new Handler(Looper.getMainLooper());
        this.currentState = RequestState.PENDING;
    }
    
    /**
     * Khởi tạo request với thông tin từ deeplink
     */
    public void initializeRequest(String requestId, String sessionId, long expirationTime) {
        Log.d(TAG, "🚀 Initializing request: " + requestId + ", expires in " + 
              ((expirationTime - System.currentTimeMillis()) / 1000) + "s");
        
        // Stop any existing polling first
        if (isPolling) {
            stopStatusPolling();
        }
        
        this.currentRequestId = requestId;
        this.currentSessionId = sessionId;
        this.expirationTime = expirationTime;
        this.currentState = RequestState.PENDING;
        this.retryCount = 0;
        this.lastRetryTime = 0;
        
        // Start status polling
        startStatusPolling();
        
        // Schedule expiration check
        scheduleExpirationCheck();
    }
    
    /**
     * Bắt đầu polling request status
     */
    private void startStatusPolling() {
        if (isPolling) return;
        
        isPolling = true;
        statusPollingRunnable = () -> {
            if (System.currentTimeMillis() >= expirationTime) {
                handleRequestExpired();
                return;
            }
            
            pollRequestStatus();
        };
        
        statusPollingFuture = scheduler.scheduleAtFixedRate(statusPollingRunnable, 
                                    STATUS_POLL_INTERVAL_MS, 
                                    STATUS_POLL_INTERVAL_MS, 
                                    TimeUnit.MILLISECONDS);
        
        Log.d(TAG, "📡 Started status polling for request: " + currentRequestId);
    }
    
    /**
     * Poll request status từ server
     */
    private void pollRequestStatus() {
        if (currentRequestId == null) return;
        
        Call<FaceIdRequestStatusResponse> call = apiController.getFaceIdRequestStatus(currentRequestId);
        call.enqueue(new retrofit2.Callback<FaceIdRequestStatusResponse>() {
            @Override
            public void onResponse(@NonNull Call<FaceIdRequestStatusResponse> call, 
                                 @NonNull retrofit2.Response<FaceIdRequestStatusResponse> response) {
                if (response.isSuccessful() && response.body() != null) {
                    handleStatusResponse(response.body());
                } else {
                    Log.w(TAG, "⚠️ Failed to get request status: HTTP " + response.code());
                    handlePollingError("HTTP " + response.code());
                }
            }
            
            @Override
            public void onFailure(@NonNull Call<FaceIdRequestStatusResponse> call, @NonNull Throwable t) {
                Log.e(TAG, "❌ Network error polling request status", t);
                handlePollingError("Network error: " + t.getMessage());
            }
        });
    }
    
    /**
     * Xử lý response status từ server
     */
    private void handleStatusResponse(FaceIdRequestStatusResponse response) {
        if (response.getData() == null) {
            Log.w(TAG, "⚠️ Invalid status response data");
            return;
        }
        
        String status = response.getData().getStatus();
        RequestState newState = parseStatus(status);
        
        if (newState != currentState) {
            Log.d(TAG, "🔄 Request state changed: " + currentState + " -> " + newState);
            currentState = newState;
            
            if (statusCallback != null) {
                mainHandler.post(() -> statusCallback.onRequestStatusUpdated(newState, response));
            }
            
            // Handle state-specific actions
            switch (newState) {
                case VERIFIED:
                    handleRequestVerified();
                    break;
                case EXPIRED:
                    handleRequestExpired();
                    break;
                case CANCELLED:
                    handleRequestCancelled();
                    break;
            }
        }
    }
    
    /**
     * Parse status string từ server thành RequestState
     */
    private RequestState parseStatus(String status) {
        if (status == null) return RequestState.PENDING;
        
        switch (status.toLowerCase()) {
            case "verified":
            case "completed":
                return RequestState.VERIFIED;
            case "expired":
            case "timeout":
                return RequestState.EXPIRED;
            case "cancelled":
                return RequestState.CANCELLED;
            case "failed":
                return RequestState.FAILED;
            default:
                return RequestState.PENDING;
        }
    }
    
    /**
     * Xử lý khi request được verify thành công
     */
    private void handleRequestVerified() {
        Log.d(TAG, "✅ Request verified successfully: " + currentRequestId);
        stopStatusPolling();
        
        if (statusCallback != null) {
            mainHandler.post(() -> statusCallback.onRequestStatusUpdated(RequestState.VERIFIED, null));
        }
    }
    
    /**
     * Xử lý khi request hết hạn
     */
    private void handleRequestExpired() {
        Log.d(TAG, "⏰ Request expired: " + currentRequestId);
        currentState = RequestState.EXPIRED;
        stopStatusPolling();
        
        if (expiredCallback != null) {
            mainHandler.post(() -> expiredCallback.onExpired());
        }
        
        if (statusCallback != null) {
            mainHandler.post(() -> statusCallback.onRequestExpired());
        }
    }
    
    /**
     * Xử lý khi request bị hủy
     */
    private void handleRequestCancelled() {
        Log.d(TAG, "❌ Request cancelled: " + currentRequestId);
        currentState = RequestState.CANCELLED;
        stopStatusPolling();
        
        if (statusCallback != null) {
            mainHandler.post(() -> statusCallback.onRequestCancelled());
        }
    }
    
    /**
     * Xử lý lỗi khi polling
     */
    private void handlePollingError(String error) {
        Log.w(TAG, "⚠️ Polling error: " + error);
        
        if (statusCallback != null) {
            mainHandler.post(() -> statusCallback.onRequestFailed(error));
        }
    }
    
    /**
     * Schedule kiểm tra expiration
     */
    private void scheduleExpirationCheck() {
        long delay = expirationTime - System.currentTimeMillis();
        if (delay > 0) {
            scheduler.schedule(() -> {
                if (System.currentTimeMillis() >= expirationTime) {
                    handleRequestExpired();
                }
            }, delay, TimeUnit.MILLISECONDS);
            
            Log.d(TAG, "⏰ Scheduled expiration check in " + (delay / 1000) + "s");
        } else {
            handleRequestExpired();
        }
    }
    
    /**
     * Dừng status polling
     */
    private void stopStatusPolling() {
        if (!isPolling) return;
        
        isPolling = false;
        
        // Cancel the scheduled task using Future.cancel()
        if (statusPollingFuture != null && !statusPollingFuture.isCancelled()) {
            statusPollingFuture.cancel(false); // false = don't interrupt if running
            statusPollingFuture = null;
        }
        
        Log.d(TAG, "🛑 Stopped status polling for request: " + currentRequestId);
    }
    
    /**
     * Hủy request hiện tại
     */
    public void cancelCurrentRequest() {
        if (currentRequestId == null) return;
        
        Log.d(TAG, "🚫 Cancelling request: " + currentRequestId);
        
        Call<Void> call = apiController.cancelFaceIdRequest(currentRequestId);
        call.enqueue(new retrofit2.Callback<Void>() {
            @Override
            public void onResponse(@NonNull Call<Void> call, @NonNull retrofit2.Response<Void> response) {
                if (response.isSuccessful()) {
                    Log.d(TAG, "✅ Request cancelled successfully");
                    handleRequestCancelled();
                } else {
                    Log.w(TAG, "⚠️ Failed to cancel request: HTTP " + response.code());
                }
            }
            
            @Override
            public void onFailure(@NonNull Call<Void> call, @NonNull Throwable t) {
                Log.e(TAG, "❌ Error cancelling request", t);
            }
        });
    }
    
    /**
     * Kiểm tra xem request có hết hạn chưa
     */
    public boolean isExpired() {
        return System.currentTimeMillis() >= expirationTime;
    }
    
    /**
     * Cleanup resources
     */
    public void cleanup() {
        stopStatusPolling();
        
        // Shutdown scheduler gracefully
        if (!scheduler.isShutdown()) {
            scheduler.shutdown();
            try {
                if (!scheduler.awaitTermination(1, TimeUnit.SECONDS)) {
                    scheduler.shutdownNow();
                }
            } catch (InterruptedException e) {
                scheduler.shutdownNow();
                Thread.currentThread().interrupt();
            }
        }
        
        Log.d(TAG, "🧹 Cleaned up FaceIdRequestManager");
    }

}
