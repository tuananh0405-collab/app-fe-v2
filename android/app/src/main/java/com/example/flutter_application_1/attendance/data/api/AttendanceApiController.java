package com.example.flutter_application_1.attendance.data.api;

import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.Header;
import retrofit2.http.POST;

import com.example.flutter_application_1.attendance.data.model.request.ValidateBeaconRequest;
import com.example.flutter_application_1.attendance.data.model.request.RequestFaceVerificationRequest;
import com.example.flutter_application_1.attendance.data.model.response.ValidateBeaconResponse;
import com.example.flutter_application_1.attendance.data.model.response.RequestFaceVerificationResponse;

/**
 * API interface for Attendance operations
 * Based on CLIENT_API_SEQUENCE.md and CLIENT_ATTENDANCE_FLOW.md
 */
public interface AttendanceApiController {
    
    /**
     * Step 1: Validate Beacon
     * Endpoint: POST /api/v1/attendance/attendance-check/validate-beacon
     * 
     * @param authorization Bearer JWT token
     * @param request Beacon validation request containing UUID, major, minor, RSSI
     * @return Response with session_token (5 minute TTL) and location info
     */
    @POST("api/v1/attendance/attendance-check/validate-beacon")
    Call<ValidateBeaconResponse> validateBeacon(
            @Body ValidateBeaconRequest request
    );
    
    /**
     * Step 2: Request Face Verification
     * Endpoint: POST /api/v1/attendance/attendance-check/request-face-verification
     * 
     * @param authorization Bearer JWT token
     * @param request Face verification request containing session_token, GPS, check_type
     * @return Response with attendance_check_id and shift_id
     */
    @POST("api/v1/attendance/attendance-check/request-face-verification")
    Call<RequestFaceVerificationResponse> requestFaceVerification(
            @Body RequestFaceVerificationRequest request
    );
}
