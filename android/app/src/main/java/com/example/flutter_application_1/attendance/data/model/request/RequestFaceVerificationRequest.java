package com.example.flutter_application_1.attendance.data.model.request;

import com.google.gson.annotations.SerializedName;

/**
 * Request model for face verification request
 * Based on CLIENT_API_SEQUENCE.md
 */
public class RequestFaceVerificationRequest {
    @SerializedName("session_token")
    private String session_token;

    @SerializedName("check_type")
    private String check_type;  // "check_in" or "check_out"

    @SerializedName("shift_date")
    private String shift_date;  // YYYY-MM-DD format

    @SerializedName("latitude")
    private Double latitude;

    @SerializedName("longitude")
    private Double longitude;

    @SerializedName("location_accuracy")
    private Double location_accuracy;

    @SerializedName("device_id")
    private String device_id;

    @SerializedName("ip_address")
    private String ip_address;

    public RequestFaceVerificationRequest(String sessionToken, String checkType, String shiftDate) {
        this.session_token = sessionToken;
        this.check_type = checkType;
        this.shift_date = shiftDate;
    }

    // Getters and Setters
    public String getSession_token() {
        return session_token;
    }

    public void setSession_token(String session_token) {
        this.session_token = session_token;
    }

    public String getCheck_type() {
        return check_type;
    }

    public void setCheck_type(String check_type) {
        this.check_type = check_type;
    }

    public String getShift_date() {
        return shift_date;
    }

    public void setShift_date(String shift_date) {
        this.shift_date = shift_date;
    }

    public Double getLatitude() {
        return latitude;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }

    public Double getLongitude() {
        return longitude;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }

    public Double getLocation_accuracy() {
        return location_accuracy;
    }

    public void setLocation_accuracy(Double location_accuracy) {
        this.location_accuracy = location_accuracy;
    }

    public String getDevice_id() {
        return device_id;
    }

    public void setDevice_id(String device_id) {
        this.device_id = device_id;
    }

    public String getIp_address() {
        return ip_address;
    }

    public void setIp_address(String ip_address) {
        this.ip_address = ip_address;
    }
}
