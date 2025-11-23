package com.example.flutter_application_1.attendance.data.model.response;

import com.google.gson.annotations.SerializedName;

/**
 * Response model for beacon validation
 * Based on CLIENT_API_SEQUENCE.md
 */
public class ValidateBeaconResponse {
    @SerializedName(value = "success", alternate = {"Success"})
    private boolean success;

    @SerializedName(value = "beacon_validated", alternate = {"BeaconValidated", "Beacon_Validated"})
    private boolean beacon_validated;

    @SerializedName(value = "beacon_id", alternate = {"BeaconId", "Beacon_Id"})
    private Integer beacon_id;

    @SerializedName(value = "location_name", alternate = {"LocationName", "Location_Name"})
    private String location_name;

    @SerializedName(value = "distance_meters", alternate = {"DistanceMeters", "Distance_Meters"})
    private Double distance_meters;

    @SerializedName(value = "session_token", alternate = {"SessionToken", "Session_Token"})
    private String session_token;

    @SerializedName(value = "expires_at", alternate = {"ExpiresAt", "Expires_At"})
    private String expires_at;

    @SerializedName(value = "message", alternate = {"Message"})
    private String message;

    // Getters and Setters
    public boolean isSuccess() {
        return success;
    }

    public void setSuccess(boolean success) {
        this.success = success;
    }

    public boolean isBeacon_validated() {
        return beacon_validated;
    }

    public void setBeacon_validated(boolean beacon_validated) {
        this.beacon_validated = beacon_validated;
    }

    public Integer getBeacon_id() {
        return beacon_id;
    }

    public void setBeacon_id(Integer beacon_id) {
        this.beacon_id = beacon_id;
    }

    public String getLocation_name() {
        return location_name;
    }

    public void setLocation_name(String location_name) {
        this.location_name = location_name;
    }

    public Double getDistance_meters() {
        return distance_meters;
    }

    public void setDistance_meters(Double distance_meters) {
        this.distance_meters = distance_meters;
    }

    public String getSession_token() {
        return session_token;
    }

    public void setSession_token(String session_token) {
        this.session_token = session_token;
    }

    public String getExpires_at() {
        return expires_at;
    }

    public void setExpires_at(String expires_at) {
        this.expires_at = expires_at;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
}
