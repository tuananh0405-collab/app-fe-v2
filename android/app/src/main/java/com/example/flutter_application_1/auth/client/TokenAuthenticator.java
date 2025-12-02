package com.example.flutter_application_1.auth.client;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.example.flutter_application_1.auth.AuthManager;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

import java.io.IOException;

import okhttp3.Authenticator;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import okhttp3.Route;

/**
 * Token Authenticator for OkHttp
 * Handles automatic token refresh when receiving 401 Unauthorized responses
 * Similar to Flutter's AuthInterceptor
 */
public class TokenAuthenticator implements Authenticator {
    private static final String TAG = "TokenAuthenticator";
    private static final String BASE_URL = "http://3.27.15.166:32527/";
    private static final String REFRESH_TOKEN_ENDPOINT = "api/v1/auth/refresh";
    private static final int MAX_RETRY_COUNT = 3;
    
    private final Context context;
    private final Gson gson = new Gson();
    private boolean isRefreshing = false;
    
    public TokenAuthenticator(Context context) {
        this.context = context;
    }
    
    @Nullable
    @Override
    public Request authenticate(@Nullable Route route, @NonNull Response response) throws IOException {
        // Check if this is a 401 response
        if (response.code() != 401) {
            return null;
        }
        
        // Avoid infinite loops - if we already tried to refresh, don't try again
        if (responseCount(response) >= MAX_RETRY_COUNT) {
            Log.e(TAG, "Max retry count reached, clearing auth");
            AuthManager.getInstance(context).clearAuth();
            return null;
        }
        
        // Skip refresh for auth endpoints to avoid infinite loops
        String path = response.request().url().encodedPath();
        if (path.contains("/auth/login") || path.contains("/auth/refresh")) {
            Log.d(TAG, "Skipping refresh for auth endpoint: " + path);
            return null;
        }
        
        // Synchronize to prevent multiple simultaneous refresh attempts
        synchronized (this) {
            AuthManager authManager = AuthManager.getInstance(context);
            String currentToken = authManager.getAuthToken();
            String refreshToken = authManager.getRefreshToken();
            
            // Check if we have a refresh token
            if (refreshToken == null || refreshToken.isEmpty()) {
                Log.e(TAG, "No refresh token available, clearing auth");
                authManager.clearAuth();
                return null;
            }
            
            // Check if another thread already refreshed the token
            String requestToken = response.request().header("Authorization");
            if (requestToken != null && !requestToken.equals("Bearer " + currentToken)) {
                // Token was already refreshed by another thread, retry with new token
                Log.d(TAG, "Token already refreshed by another thread, retrying request");
                return response.request().newBuilder()
                        .header("Authorization", "Bearer " + currentToken)
                        .build();
            }
            
            // Perform token refresh
            try {
                Log.d(TAG, "Attempting to refresh token");
                String newAccessToken = refreshAccessToken(refreshToken);
                
                if (newAccessToken != null && !newAccessToken.isEmpty()) {
                    Log.d(TAG, "✅ Token refreshed successfully");
                    
                    // Retry the request with new token
                    return response.request().newBuilder()
                            .header("Authorization", "Bearer " + newAccessToken)
                            .build();
                } else {
                    Log.e(TAG, "Failed to refresh token, clearing auth");
                    authManager.clearAuth();
                    return null;
                }
            } catch (Exception e) {
                Log.e(TAG, "Error refreshing token", e);
                authManager.clearAuth();
                return null;
            }
        }
    }
    
    /**
     * Refresh the access token using the refresh token
     * Similar to Flutter's _refreshToken method
     */
    private String refreshAccessToken(String refreshToken) throws IOException {
        // Create a new OkHttpClient without authenticator to avoid recursion
        OkHttpClient client = new OkHttpClient.Builder()
                .connectTimeout(30, java.util.concurrent.TimeUnit.SECONDS)
                .readTimeout(30, java.util.concurrent.TimeUnit.SECONDS)
                .writeTimeout(30, java.util.concurrent.TimeUnit.SECONDS)
                .build();
        
        // Create request body
        JsonObject requestBody = new JsonObject();
        requestBody.addProperty("refresh_token", refreshToken);
        
        RequestBody body = RequestBody.create(
                MediaType.parse("application/json"),
                gson.toJson(requestBody)
        );
        
        // Build request
        Request request = new Request.Builder()
                .url(BASE_URL + REFRESH_TOKEN_ENDPOINT)
                .post(body)
                .build();
        
        // Execute request
        try (Response response = client.newCall(request).execute()) {
            if (response.isSuccessful() && response.body() != null) {
                String responseBody = response.body().string();
                JsonObject jsonResponse = gson.fromJson(responseBody, JsonObject.class);
                
                // Handle ApiResponseModel wrapper (similar to Flutter)
                JsonObject tokenData = null;
                if (jsonResponse.has("data") && jsonResponse.get("data").isJsonObject()) {
                    // Response is wrapped in ApiResponseModel
                    tokenData = jsonResponse.getAsJsonObject("data");
                } else if (jsonResponse.has("access_token")) {
                    // Response is direct
                    tokenData = jsonResponse;
                }
                
                if (tokenData != null && tokenData.has("access_token")) {
                    String newAccessToken = tokenData.get("access_token").getAsString();
                    String newRefreshToken = tokenData.has("refresh_token") 
                            ? tokenData.get("refresh_token").getAsString() 
                            : refreshToken;
                    
                    // Update tokens in AuthManager atomically
                    AuthManager authManager = AuthManager.getInstance(context);
                    authManager.updateTokens(newAccessToken, newRefreshToken);
                    
                    Log.d(TAG, "✅ Tokens updated in AuthManager");
                    return newAccessToken;
                }
            } else {
                Log.e(TAG, "❌ Refresh token failed: HTTP " + response.code());
            }
        }
        
        return null;
    }
    
    /**
     * Count how many times we've tried to authenticate this request
     */
    private int responseCount(Response response) {
        int result = 1;
        Response priorResponse = response.priorResponse();
        while (priorResponse != null) {
            result++;
            priorResponse = priorResponse.priorResponse();
        }
        return result;
    }
}
