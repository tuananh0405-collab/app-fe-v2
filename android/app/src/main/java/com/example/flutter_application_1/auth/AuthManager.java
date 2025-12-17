package com.example.flutter_application_1.auth;

import android.content.Context;
import android.content.SharedPreferences;

/**
 * Simple AuthManager for Face ID integration
 */
public class AuthManager {
    private static final String PREFS_NAME = "AppPrefs";
    private static final String KEY_USER_ID = "userId";
    private static final String KEY_EMPLOYEE_ID = "employeeId";
    private static final String KEY_AUTH_TOKEN = "authToken";
    private static final String KEY_REFRESH_TOKEN = "refreshToken";
    private static final String KEY_USER_NAME = "userName";
    private static final String KEY_FACE_ID_REGISTERED = "faceIdRegistered";
    
    private static AuthManager instance;
    private final SharedPreferences prefs;
    
    private AuthManager(Context context) {
        this.prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
    }
    
    public static synchronized AuthManager getInstance(Context context) {
        if (instance == null) {
            instance = new AuthManager(context.getApplicationContext());
        }
        return instance;
    }
    
    public String getUserId() {
        return prefs.getString(KEY_USER_ID, null);
    }

    /**
     * Backwards-compatible method name used by older faceid code.
     */
    public String getCurrentUserId() {
        return getUserId();
    }
    
    public void setUserId(String userId) {
        prefs.edit().putString(KEY_USER_ID, userId).apply();
    }
    
    public String getAuthToken() {
        return prefs.getString(KEY_AUTH_TOKEN, "");
    }
    
    public void setAuthToken(String token) {
        prefs.edit().putString(KEY_AUTH_TOKEN, token).apply();
    }
    
    public String getRefreshToken() {
        return prefs.getString(KEY_REFRESH_TOKEN, "");
    }
    
    public void setRefreshToken(String refreshToken) {
        prefs.edit().putString(KEY_REFRESH_TOKEN, refreshToken).apply();
    }
    
    /**
     * Update both access token and refresh token atomically
     * This is useful when refreshing tokens to ensure consistency
     */
    public void updateTokens(String accessToken, String refreshToken) {
        prefs.edit()
                .putString(KEY_AUTH_TOKEN, accessToken)
                .putString(KEY_REFRESH_TOKEN, refreshToken)
                .apply();
    }
    
    public boolean isFaceIdRegistered() {
        return prefs.getBoolean(KEY_FACE_ID_REGISTERED, false);
    }
    
    public void setFaceIdRegistered(boolean registered) {
        prefs.edit().putBoolean(KEY_FACE_ID_REGISTERED, registered).apply();
    }

    public String getCurrentUserName() {
        return prefs.getString(KEY_USER_NAME, "");
    }

    public void setCurrentUserName(String name) {
        prefs.edit().putString(KEY_USER_NAME, name).apply();
    }

    public String getEmployeeId() {
        return prefs.getString(KEY_EMPLOYEE_ID, null);
    }

    public void setEmployeeId(String employeeId) {
        prefs.edit().putString(KEY_EMPLOYEE_ID, employeeId).apply();
    }
    
    public void clearAuth() {
        prefs.edit().clear().apply();
    }
}
