package com.example.flutter_application_1.attendance.data.service;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import com.example.flutter_application_1.attendance.data.api.AttendanceApiController;
import com.example.flutter_application_1.attendance.data.model.request.RequestFaceVerificationRequest;
import com.example.flutter_application_1.attendance.data.model.response.RequestFaceVerificationResponse;
import com.example.flutter_application_1.auth.AuthManager;
import com.example.flutter_application_1.auth.client.ApiClient;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

/**
 * Service for handling attendance face verification requests
 * Focuses on coordinating face verification API calls
 * 
 * Note: Beacon validation is handled by BeaconsService
 * Note: GPS retrieval is handled by GPSService
 * 
 * Based on CLIENT_API_SEQUENCE.md and CLIENT_ATTENDANCE_FLOW.md
 */
public class AttendanceService {
    private static final String TAG = "AttendanceService";
    
    private final Context context;
    private final AttendanceApiController attendanceApi;
    
    // State
    private Integer currentAttendanceCheckId;
    private Integer currentShiftId;
    
    public AttendanceService(Context context) {
        this.context = context;
        this.attendanceApi = ApiClient.getClient(context).create(AttendanceApiController.class);
    }
    
    /**
     * Request Face Verification
     * 
     * @param sessionToken Session token from beacon validation (BeaconsService)
     * @param checkType "check_in" or "check_out"
     * @param latitude GPS latitude (from GPSService)
     * @param longitude GPS longitude (from GPSService)
     * @param locationAccuracy GPS accuracy in meters
     * @param deviceId Device identifier
     * @param faceEmbeddingBase64 Face embedding from MediaPipe (FaceIdService)
     * @param callback Callback for result
     */
    public void requestFaceVerification(
            String sessionToken,
            String checkType,
            Double latitude,
            Double longitude,
            Double locationAccuracy,
            String deviceId,
            String faceEmbeddingBase64,
            AttendanceCallback<RequestFaceVerificationResponse> callback) {
        
        Log.d(TAG, "🎯 Requesting face verification");
        Log.d(TAG, "Check type: " + checkType);
        Log.d(TAG, "GPS: " + latitude + ", " + longitude + " (accuracy: " + locationAccuracy + "m)");
        Log.d(TAG, "Face embedding: " + (faceEmbeddingBase64 != null ? faceEmbeddingBase64.length() + " chars" : "null"));
        
        // Validate session token
        if (sessionToken == null || sessionToken.isEmpty()) {
            Log.e(TAG, "❌ No session token provided");
            callback.onFailure("No valid session token. Please validate beacon first.");
            return;
        }
        
        Log.d(TAG, "📝 Using session token: " + sessionToken);
        
        // Get JWT token
        String token = AuthManager.getInstance(context).getAuthToken();
        if (token == null || token.isEmpty()) {
            callback.onFailure("Not authenticated. Please log in.");
            return;
        }
        
        // Get current date for shift_date
        String shiftDate = new SimpleDateFormat("yyyy-MM-dd", Locale.US).format(new Date());
        
        // Create request
        RequestFaceVerificationRequest request = new RequestFaceVerificationRequest(
                sessionToken, checkType, shiftDate);
        request.setLatitude(latitude);
        request.setLongitude(longitude);
        request.setLocation_accuracy(locationAccuracy);
        request.setDevice_id(deviceId);
        request.setFace_embedding_base64(faceEmbeddingBase64);
        
        // Call API
        Call<RequestFaceVerificationResponse> call = attendanceApi.requestFaceVerification(request);
        
        call.enqueue(new Callback<RequestFaceVerificationResponse>() {
            @Override
            public void onResponse(@NonNull Call<RequestFaceVerificationResponse> call,
                                 @NonNull Response<RequestFaceVerificationResponse> response) {
                if (response.isSuccessful() && response.body() != null) {
                    RequestFaceVerificationResponse body = response.body();
                    
                    if (body.isSuccess()) {
                        // Save attendance check ID
                        currentAttendanceCheckId = body.getAttendance_check_id();
                        currentShiftId = body.getShift_id();
                        Log.d(TAG, "✅ Face verification requested!");
                        Log.d(TAG, "📝 Attendance Check ID: " + currentAttendanceCheckId);
                        Log.d(TAG, "📅 Shift ID: " + currentShiftId);
                        callback.onSuccess(body);
                    } else {
                        callback.onFailure(body.getMessage() != null ? 
                                body.getMessage() : "Face verification request failed");
                    }
                } else {
                    String errorMsg = "Face verification request failed: HTTP " + response.code();
                    if (response.code() == 400) {
                        errorMsg = "Session token expired. Please scan beacon again.";
                    }
                    callback.onFailure(errorMsg);
                }
            }
            
            @Override
            public void onFailure(@NonNull Call<RequestFaceVerificationResponse> call,
                                @NonNull Throwable t) {
                Log.e(TAG, "❌ Face verification request network error", t);
                callback.onFailure("Network error: " + t.getMessage());
            }
        });
    }
    
    /**
     * Reset state
     */
    public void resetSession() {
        currentAttendanceCheckId = null;
        currentShiftId = null;
        Log.d(TAG, "🔄 State reset");
    }
    
    /**
     * Get current attendance check ID
     */
    public Integer getCurrentAttendanceCheckId() {
        return currentAttendanceCheckId;
    }
    
    /**
     * Callback interface for attendance operations
     */
    public interface AttendanceCallback<T> {
        void onSuccess(T result);
        void onFailure(String error);
    }
}
