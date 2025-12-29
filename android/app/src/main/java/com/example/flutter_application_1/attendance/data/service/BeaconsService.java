package com.example.flutter_application_1.attendance.data.service;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import com.example.flutter_application_1.attendance.data.api.AttendanceApiController;
import com.example.flutter_application_1.attendance.data.model.request.ValidateBeaconRequest;
import com.example.flutter_application_1.attendance.data.model.response.ValidateBeaconResponse;
import com.example.flutter_application_1.auth.client.ApiClient;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

/**
 * Service for handling beacon validation
 * Manages beacon validation API calls and session token lifecycle
 */
public class BeaconsService {
    private static final String TAG = "BeaconsService";
    
    private final Context context;
    private final AttendanceApiController attendanceApi;
    
    // Session state
    private String currentSessionToken;
    
    /**
     * Callback interface for beacon validation
     */
    public interface BeaconCallback {
        void onSuccess(ValidateBeaconResponse response);
        void onFailure(String error);
    }
    
    public BeaconsService(Context context) {
        this.context = context;
        this.attendanceApi = ApiClient.getClient(context).create(AttendanceApiController.class);
    }
    
    /**
     * Validate Beacon
     * 
     * @param beaconUuid Beacon UUID (e.g., "FDA50693-A4E2-4FB1-AFCF-C6EB07647825")
     * @param beaconMajor Beacon major number
     * @param beaconMinor Beacon minor number
     * @param rssi Signal strength in dBm
     * @param callback Callback for result
     */
    public void validateBeacon(
            String beaconUuid,
            int beaconMajor,
            int beaconMinor,
            int rssi,
            BeaconCallback callback) {
        
        Log.d(TAG, "📡 Validating beacon - UUID: " + beaconUuid + 
                ", Major: " + beaconMajor + ", Minor: " + beaconMinor + ", RSSI: " + rssi);
        
        // Create request
        ValidateBeaconRequest request = new ValidateBeaconRequest(
                beaconUuid, beaconMajor, beaconMinor, rssi);
        
        // Call API
        Call<ValidateBeaconResponse> call = attendanceApi.validateBeacon(request);
        
        call.enqueue(new Callback<ValidateBeaconResponse>() {
            @Override
            public void onResponse(@NonNull Call<ValidateBeaconResponse> call,
                                 @NonNull Response<ValidateBeaconResponse> response) {
                if (response.isSuccessful() && response.body() != null) {
                    ValidateBeaconResponse body = response.body();
                    
                    if (body.isSuccess() && body.isBeacon_validated()) {
                        // Save session token
                        currentSessionToken = body.getSession_token();
                        Log.d(TAG, "✅ Beacon validated! Session token: " + currentSessionToken);
                        Log.d(TAG, "📍 Location: " + body.getLocation_name());
                        Log.d(TAG, "⏰ Expires at: " + body.getExpires_at());
                        callback.onSuccess(body);
                    } else {
                        String errorMsg = body.getMessage() != null ? 
                                body.getMessage() : "Beacon validation failed";
                        Log.e(TAG, "❌ Beacon validation failed: " + errorMsg);
                        callback.onFailure(errorMsg);
                    }
                } else {
                    String errorMsg = "Beacon validation failed: HTTP " + response.code();
                    Log.e(TAG, "❌ " + errorMsg);
                    callback.onFailure(errorMsg);
                }
            }
            
            @Override
            public void onFailure(@NonNull Call<ValidateBeaconResponse> call,
                                @NonNull Throwable t) {
                String errorMsg = "Network error: " + t.getMessage();
                Log.e(TAG, "❌ Beacon validation network error", t);
                callback.onFailure(errorMsg);
            }
        });
    }
    
    /**
     * Get current session token
     * 
     * @return Current session token, or null if not available
     */
    public String getCurrentSessionToken() {
        return currentSessionToken;
    }
    
    /**
     * Reset session state
     */
    public void resetSession() {
        currentSessionToken = null;
        Log.d(TAG, "🔄 Session reset");
    }
}
