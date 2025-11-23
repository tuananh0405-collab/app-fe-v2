package com.example.flutter_application_1.attendance.data.model.response;

import com.google.gson.annotations.SerializedName;

/**
 * Response model for face verification request
 * Based on CLIENT_API_SEQUENCE.md
 */
public class RequestFaceVerificationResponse {
    @SerializedName(value = "success", alternate = {"Success"})
    private boolean success;

    @SerializedName(value = "attendance_check_id", alternate = {"AttendanceCheckId", "Attendance_Check_Id"})
    private Integer attendance_check_id;

    @SerializedName(value = "shift_id", alternate = {"ShiftId", "Shift_Id"})
    private Integer shift_id;

    @SerializedName(value = "message", alternate = {"Message"})
    private String message;

    // Getters and Setters
    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public Integer getAttendance_check_id() {
        return attendance_check_id;
    }

    public void setAttendance_check_id(Integer attendance_check_id) {
        this.attendance_check_id = attendance_check_id;
    }

    public Integer getShift_id() {
        return shift_id;
    }

    public void setShift_id(Integer shift_id) {
        this.shift_id = shift_id;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
