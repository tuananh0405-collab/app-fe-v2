package com.example.flutter_application_1.auth.client;

import android.content.Context;
import android.util.Log;

import com.example.flutter_application_1.auth.AuthManager;

/**
 * Helper class to test token refresh functionality
 * 
 * Usage:
 * 1. Set valid access and refresh tokens
 * 2. Make an API call
 * 3. Check logs to see if token refresh works
 */
public class TokenRefreshTestHelper {
    private static final String TAG = "TokenRefreshTest";
    
    /**
     * Set test tokens for debugging
     * Call this after login to ensure refresh token is stored
     */
    public static void setTestTokens(Context context, String accessToken, String refreshToken) {
        AuthManager authManager = AuthManager.getInstance(context);
        authManager.updateTokens(accessToken, refreshToken);
        
        Log.d(TAG, "✅ Test tokens set:");
        Log.d(TAG, "Access Token: " + (accessToken != null ? accessToken.substring(0, Math.min(20, accessToken.length())) + "..." : "null"));
        Log.d(TAG, "Refresh Token: " + (refreshToken != null ? refreshToken.substring(0, Math.min(20, refreshToken.length())) + "..." : "null"));
    }
    
    /**
     * Verify that tokens are stored correctly
     */
    public static boolean verifyTokensStored(Context context) {
        AuthManager authManager = AuthManager.getInstance(context);
        String accessToken = authManager.getAuthToken();
        String refreshToken = authManager.getRefreshToken();
        
        boolean hasAccessToken = accessToken != null && !accessToken.isEmpty();
        boolean hasRefreshToken = refreshToken != null && !refreshToken.isEmpty();
        
        Log.d(TAG, "Token verification:");
        Log.d(TAG, "Has Access Token: " + hasAccessToken);
        Log.d(TAG, "Has Refresh Token: " + hasRefreshToken);
        
        return hasAccessToken && hasRefreshToken;
    }
    
    /**
     * Clear all tokens (for testing logout)
     */
    public static void clearTokens(Context context) {
        AuthManager authManager = AuthManager.getInstance(context);
        authManager.clearAuth();
        Log.d(TAG, "✅ All tokens cleared");
    }
    
    /**
     * Print current token status
     */
    public static void printTokenStatus(Context context) {
        AuthManager authManager = AuthManager.getInstance(context);
        String accessToken = authManager.getAuthToken();
        String refreshToken = authManager.getRefreshToken();
        
        Log.d(TAG, "=== Current Token Status ===");
        Log.d(TAG, "Access Token: " + (accessToken != null && !accessToken.isEmpty() ? 
                accessToken.substring(0, Math.min(30, accessToken.length())) + "..." : "EMPTY"));
        Log.d(TAG, "Refresh Token: " + (refreshToken != null && !refreshToken.isEmpty() ? 
                refreshToken.substring(0, Math.min(30, refreshToken.length())) + "..." : "EMPTY"));
        Log.d(TAG, "User ID: " + authManager.getUserId());
        Log.d(TAG, "===========================");
    }
}
