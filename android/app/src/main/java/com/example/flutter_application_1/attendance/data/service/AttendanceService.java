package com.example.flutter_application_1.attendance.data.service;

import android.content.Context;
import android.graphics.Bitmap;
import android.util.Log;

import androidx.annotation.NonNull;

import com.example.flutter_application_1.attendance.data.api.AttendanceApiController;
import com.example.flutter_application_1.attendance.data.model.request.RequestFaceVerificationRequest;
import com.example.flutter_application_1.attendance.data.model.request.ValidateBeaconRequest;
import com.example.flutter_application_1.attendance.data.model.response.RequestFaceVerificationResponse;
import com.example.flutter_application_1.attendance.data.model.response.ValidateBeaconResponse;
import com.example.flutter_application_1.auth.AuthManager;
import com.example.flutter_application_1.auth.client.ApiClient;
import com.example.flutter_application_1.faceid.data.api.FaceIdApiController;
import com.example.flutter_application_1.faceid.data.model.response.FaceIdVerifyResponse;

import java.io.ByteArrayOutputStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import okhttp3.MediaType;
import okhttp3.MultipartBody;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

/**
 * Service for handling attendance check-in flow
 * Implements the 3-step verification process:
 * 1. Beacon Validation
 * 2. GPS Validation + Face Verification Request
 * 3. Face Image Upload
 * 
 * Based on CLIENT_API_SEQUENCE.md and CLIENT_ATTENDANCE_FLOW.md
 */
public class AttendanceService {
    private static final String TAG = "AttendanceService";
    
    private final Context context;
    private final AttendanceApiController attendanceApi;
    private final FaceIdApiController faceIdApi;
    
    // Session state
    private String currentSessionToken;
    private Integer currentAttendanceCheckId;
    private Integer currentShiftId;
    
    public AttendanceService(Context context) {
        this.context = context;
        this.attendanceApi = ApiClient.getClient(context).create(AttendanceApiController.class);
        this.faceIdApi = ApiClient.getClient(context).create(FaceIdApiController.class);
    }
    
    /**
     * Step 1: Validate Beacon
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
            AttendanceCallback<ValidateBeaconResponse> callback) {
        
        Log.d(TAG, "📡 Step 1: Validating beacon - UUID: " + beaconUuid + 
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
                        // Save session token for next step
                        currentSessionToken = body.getSession_token();
                        Log.d(TAG, "✅ Beacon validated! Session token: " + currentSessionToken);
                        Log.d(TAG, "📍 Location: " + body.getLocation_name());
                        Log.d(TAG, "⏰ Expires at: " + body.getExpires_at());
                        callback.onSuccess(body);
                    } else {
                        callback.onFailure(body.getMessage() != null ? 
                                body.getMessage() : "Beacon validation failed");
                    }
                } else {
                    callback.onFailure("Beacon validation failed: HTTP " + response.code());
                }
            }
            
            @Override
            public void onFailure(@NonNull Call<ValidateBeaconResponse> call,
                                @NonNull Throwable t) {
                Log.e(TAG, "❌ Beacon validation network error", t);
                callback.onFailure("Network error: " + t.getMessage());
            }
        });
    }
    
    /**
     * Step 2: Request Face Verification
     * 
     * @param checkType "check_in" or "check_out"
     * @param latitude GPS latitude (optional but recommended)
     * @param longitude GPS longitude (optional but recommended)
     * @param locationAccuracy GPS accuracy in meters
     * @param deviceId Device identifier
     * @param callback Callback for result
     */
    public void requestFaceVerification(
            String checkType,
            Double latitude,
            Double longitude,
            Double locationAccuracy,
            String deviceId,
            AttendanceCallback<RequestFaceVerificationResponse> callback) {
        
        Log.d(TAG, "🎯 Step 2: Requesting face verification");
        Log.d(TAG, "Check type: " + checkType);
        Log.d(TAG, "GPS: " + latitude + ", " + longitude + " (accuracy: " + locationAccuracy + "m)");
        
        // Validate session token
        if (currentSessionToken == null || currentSessionToken.isEmpty()) {
            callback.onFailure("No valid session token. Please validate beacon first.");
            return;
        }
        
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
                currentSessionToken, checkType, shiftDate);
        request.setLatitude(latitude);
        request.setLongitude(longitude);
        request.setLocation_accuracy(locationAccuracy);
        request.setDevice_id(deviceId);
        
    // Call API
    Call<RequestFaceVerificationResponse> call = attendanceApi.requestFaceVerification(request);
        
        call.enqueue(new Callback<RequestFaceVerificationResponse>() {
            @Override
            public void onResponse(@NonNull Call<RequestFaceVerificationResponse> call,
                                 @NonNull Response<RequestFaceVerificationResponse> response) {
                if (response.isSuccessful() && response.body() != null) {
                    RequestFaceVerificationResponse body = response.body();
                    
                    if (body.isSuccess()) {
                        // Save attendance check ID for next step
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
     * Step 3: Upload Face Image for Verification
     * 
     * @param faceImage Captured face image
     * @param checkType "check_in" or "check_out"
     * @param callback Callback for result
     */
    public void uploadFaceImage(
            Bitmap faceImage,
            String checkType,
            AttendanceCallback<FaceIdVerifyResponse> callback) {
        
        Log.d(TAG, "📸 Step 3: Uploading face image for verification");
        
        // Validate attendance check ID
        if (currentAttendanceCheckId == null) {
            callback.onFailure("No attendance check ID. Please request face verification first.");
            return;
        }
        
        // Get user info
        String userId = AuthManager.getInstance(context).getCurrentUserId();
        String employeeCode = AuthManager.getInstance(context).getCurrentUserName(); // Using username as employee code
        
        if (userId == null || userId.isEmpty()) {
            callback.onFailure("User not logged in");
            return;
        }
        
        try {
            // Convert bitmap to JPEG byte array
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            faceImage.compress(Bitmap.CompressFormat.JPEG, 90, baos);
            byte[] imageBytes = baos.toByteArray();
            
            // Create multipart request
            RequestBody attendanceCheckIdPart = RequestBody.create(
                    MediaType.parse("text/plain"), 
                    String.valueOf(currentAttendanceCheckId));
            
            RequestBody employeeIdPart = RequestBody.create(
                    MediaType.parse("text/plain"), 
                    userId);
            
            RequestBody employeeCodePart = RequestBody.create(
                    MediaType.parse("text/plain"), 
                    employeeCode);
            
            RequestBody checkTypePart = RequestBody.create(
                    MediaType.parse("text/plain"), 
                    checkType);
            
            RequestBody imageBody = RequestBody.create(
                    MediaType.parse("image/jpeg"), 
                    imageBytes);
            
            MultipartBody.Part imagePart = MultipartBody.Part.createFormData(
                    "FaceImage", "face.jpg", imageBody);
            
            // Call Face ID API for attendance verification
            Log.d(TAG, "Uploading face image - AttendanceCheckId: " + currentAttendanceCheckId + 
                    ", EmployeeId: " + userId + ", CheckType: " + checkType);
            
            Call<FaceIdVerifyResponse> call = faceIdApi.verifyFaceForAttendance(
                    attendanceCheckIdPart,
                    employeeIdPart,
                    employeeCodePart,
                    checkTypePart,
                    imagePart
            );
            
            call.enqueue(new Callback<FaceIdVerifyResponse>() {
                @Override
                public void onResponse(@NonNull Call<FaceIdVerifyResponse> call,
                                     @NonNull Response<FaceIdVerifyResponse> response) {
                    if (response.isSuccessful() && response.body() != null) {
                        FaceIdVerifyResponse body = response.body();
                        
                        if (body.isSuccess()) {
                            Log.d(TAG, "✅ Face verified for attendance!");
                            Log.d(TAG, "Similarity: " + body.getSimilarity());
                            callback.onSuccess(body);
                        } else {
                            callback.onFailure(body.getMessage() != null ? 
                                    body.getMessage() : "Face verification failed");
                        }
                    } else {
                        callback.onFailure("Face verification failed: HTTP " + response.code());
                    }
                }
                
                @Override
                public void onFailure(@NonNull Call<FaceIdVerifyResponse> call,
                                    @NonNull Throwable t) {
                    Log.e(TAG, "❌ Face upload network error", t);
                    callback.onFailure("Network error: " + t.getMessage());
                }
            });
            
        } catch (Exception e) {
            Log.e(TAG, "❌ Error uploading face image", e);
            callback.onFailure("Error: " + e.getMessage());
        }
    }
    
    /**
     * Complete check-in flow (all 3 steps)
     * This is a convenience method that chains all steps together
     */
    public void performCheckIn(
            String beaconUuid,
            int beaconMajor,
            int beaconMinor,
            int rssi,
            Double latitude,
            Double longitude,
            Double locationAccuracy,
            String deviceId,
            Bitmap faceImage,
            AttendanceCallback<String> callback) {
        
        Log.d(TAG, "🚀 Starting complete check-in flow (production API)");

        // Step 1: Validate Beacon (only JWT in header)
        validateBeacon(beaconUuid, beaconMajor, beaconMinor, rssi,
            new AttendanceCallback<ValidateBeaconResponse>() {
                @Override
                public void onSuccess(ValidateBeaconResponse beaconResult) {
                     uploadFaceImage(faceImage, "check_in",
                                    new AttendanceCallback<FaceIdVerifyResponse>() {
                                        @Override
                                        public void onSuccess(FaceIdVerifyResponse faceResult) {
                                            Log.d(TAG, "Step 3 ✅ - Face verified: " + faceResult.getMessage());
                                            callback.onSuccess("Check-in successful! " + faceResult.getMessage());
                                        }
                                        @Override
                                        public void onFailure(String error) {
                                            callback.onFailure("Step 3 failed: " + error);
                                        }
                                    });
                            

                    Log.d(TAG, "Step 1 ✅ - Beacon validated, session_token: " + beaconResult.getSession_token());
                    // Step 2: Request Face Verification (only JWT in header)
                    // requestFaceVerification("check_in", latitude, longitude, locationAccuracy, deviceId,
                    //     new AttendanceCallback<RequestFaceVerificationResponse>() {
                    //         @Override
                    //         public void onSuccess(RequestFaceVerificationResponse verifyResult) {
                    //             Log.d(TAG, "Step 2 ✅ - AttendanceCheckId: " + verifyResult.getAttendance_check_id());
                    //             // Step 3: Upload Face Image
                    //             uploadFaceImage(faceImage, "check_in",
                    //                 new AttendanceCallback<FaceIdVerifyResponse>() {
                    //                     @Override
                    //                     public void onSuccess(FaceIdVerifyResponse faceResult) {
                    //                         Log.d(TAG, "Step 3 ✅ - Face verified: " + faceResult.getMessage());
                    //                         callback.onSuccess("Check-in successful! " + faceResult.getMessage());
                    //                     }
                    //                     @Override
                    //                     public void onFailure(String error) {
                    //                         callback.onFailure("Step 3 failed: " + error);
                    //                     }
                    //                 });
                    //         }
                    //         @Override
                    //         public void onFailure(String error) {
                    //             // Handle session token expiry
                    //             if (error != null && error.contains("Session token expired")) {
                    //                 callback.onFailure("Step 2 failed: Session token expired. Please scan beacon again.");
                    //             } else {
                    //                 callback.onFailure("Step 2 failed: " + error);
                    //             }
                    //         }
                    //     });
                }
                @Override
                public void onFailure(String error) {
                    callback.onFailure("Step 1 failed: " + error);
                }
            });
    }
    
    /**
     * Reset session state
     */
    public void resetSession() {
        currentSessionToken = null;
        currentAttendanceCheckId = null;
        currentShiftId = null;
        Log.d(TAG, "Session reset");
    }
    
    /**
     * Get current session token
     */
    public String getCurrentSessionToken() {
        return currentSessionToken;
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
