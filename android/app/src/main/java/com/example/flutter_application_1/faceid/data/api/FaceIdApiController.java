package com.example.flutter_application_1.faceid.data.api;

import okhttp3.MultipartBody;
import okhttp3.RequestBody;
import retrofit2.Call;
import retrofit2.http.GET;
import retrofit2.http.PATCH;
import retrofit2.http.Multipart;
import retrofit2.http.POST;
import retrofit2.http.Part;
import retrofit2.http.Path;
import com.example.flutter_application_1.faceid.data.model.response.FaceIdRequestStatusResponse;
import com.example.flutter_application_1.faceid.data.model.response.FaceIdResponse;
import com.example.flutter_application_1.faceid.data.model.response.FaceIdVerifyResponse;

/**
 * API interface for Face ID operations
 */
public interface FaceIdApiController {
    
    /**
     * Register a new face ID
     * @param embedding Face embedding data
     * @param userId User ID
     * @return Response indicating success or failure
     */
    @Multipart
    @POST("api/v1/face/faceid/register")
    Call<FaceIdResponse> registerFaceId(
            @Part MultipartBody.Part embedding,
            @Part("userId") RequestBody userId
    );
    
    /**
     * Update an existing face ID
     * @param embedding Face embedding data
     * @param userId User ID
     * @return Response indicating success or failure
     */
    @Multipart
    @POST("api/v1/face/faceid/update")
    Call<FaceIdResponse> updateFaceId(
            @Part MultipartBody.Part embedding,
            @Part("userId") RequestBody userId
    );
    
    /**
     * Verify a face ID (request-based, requires requestId from notification)
     * @param requestId Request ID from notification
     * @param userId User ID
     * @param embedding Face embedding data
     * @param threshold Optional threshold
     * @return Response indicating success or failure
     */
    @Multipart
    @POST("api/faceid/requests/{requestId}/verify")
    Call<FaceIdVerifyResponse> verifyFaceId(
            @Path("requestId") String requestId,
            @Part("userId") RequestBody userId,
            @Part MultipartBody.Part embedding,
            @Part("threshold") RequestBody threshold,
            @Part("latitude") RequestBody latitude,
            @Part("longitude") RequestBody longitude,
            @Part("location_accuracy") RequestBody locationAccuracy,
            @Part("device_id") RequestBody deviceId,
            @Part("ip_address") RequestBody ipAddress
    );

    /**
     * Verify a face ID (ad-hoc, no request needed)
     * @param userId User ID
     * @param embedding Face embedding data
     * @param threshold Optional threshold
     * @return Response indicating success or failure
     */
    @Multipart
    @POST("api/v1/face/faceid/verify")
    Call<FaceIdVerifyResponse> verifyFaceIdAdHoc(
            @Part("userId") RequestBody userId,
            @Part MultipartBody.Part embedding,
            @Part("threshold") RequestBody threshold
    );

    @PATCH("api/faceid/requests/{requestId}/cancel")
    Call<Void> cancelFaceIdRequest(@Path("requestId") String requestId);

    @GET("api/faceid/requests/{requestId}/status")
    Call<FaceIdRequestStatusResponse> getFaceIdRequestStatus(@Path("requestId") String requestId);
    
    /**
     * Verify face for attendance check-in/check-out
     * Endpoint: POST /api/face-id/attendance/verify
     * Based on CLIENT_API_SEQUENCE.md
     * 
     * @param attendanceCheckId Attendance check ID from step 2
     * @param employeeId Employee ID
     * @param employeeCode Employee code
     * @param checkType "check_in" or "check_out"
     * @param faceImage Face image file (JPEG/PNG, max 5MB)
     * @return Response indicating success or failure
     */
    @Multipart
    @POST("api/face-id/attendance/verify")
    Call<FaceIdVerifyResponse> verifyFaceForAttendance(
            @Part("AttendanceCheckId") RequestBody attendanceCheckId,
            @Part("EmployeeId") RequestBody employeeId,
            @Part("EmployeeCode") RequestBody employeeCode,
            @Part("CheckType") RequestBody checkType,
            @Part MultipartBody.Part faceImage
    );
} 
