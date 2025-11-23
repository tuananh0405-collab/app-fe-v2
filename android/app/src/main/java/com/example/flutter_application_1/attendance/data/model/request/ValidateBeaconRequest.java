package com.example.flutter_application_1.attendance.data.model.request;

import com.google.gson.annotations.SerializedName;

/**
 * Request model for beacon validation
 * Based on CLIENT_API_SEQUENCE.md
 */
public class ValidateBeaconRequest {
    @SerializedName("beacon_uuid")
    private String beacon_uuid;

    @SerializedName("beacon_major")
    private int beacon_major;

    @SerializedName("beacon_minor")
    private int beacon_minor;

    @SerializedName("rssi")
    private int rssi;

    public ValidateBeaconRequest(String beaconUuid, int beaconMajor, int beaconMinor, int rssi) {
        this.beacon_uuid = beaconUuid;
        this.beacon_major = beaconMajor;
        this.beacon_minor = beaconMinor;
        this.rssi = rssi;
    }

    // Getters and Setters
    public String getBeacon_uuid() {
        return beacon_uuid;
    }

    public void setBeacon_uuid(String beacon_uuid) {
        this.beacon_uuid = beacon_uuid;
    }

    public int getBeacon_major() {
        return beacon_major;
    }

    public void setBeacon_major(int beacon_major) {
        this.beacon_major = beacon_major;
    }

    public int getBeacon_minor() {
        return beacon_minor;
    }

    public void setBeacon_minor(int beacon_minor) {
        this.beacon_minor = beacon_minor;
    }

    public int getRssi() {
        return rssi;
    }

    public void setRssi(int rssi) {
        this.rssi = rssi;
    }
}
