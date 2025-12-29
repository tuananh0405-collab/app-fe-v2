package com.example.flutter_application_1.auth.client;

import android.content.Context;
import android.util.Log;
import com.example.flutter_application_1.auth.AuthManager;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.logging.HttpLoggingInterceptor;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

import java.util.concurrent.TimeUnit;

/**
 * API Client for making HTTP requests
 */
public class ApiClient {
    // Face ID API Base URL
    private static final String BASE_URL = "http://3.27.15.166:32527/";
    private static Retrofit retrofit = null;

    public static Retrofit getClient(Context context) {
        if (retrofit == null) {
            HttpLoggingInterceptor logging = new HttpLoggingInterceptor();
            logging.setLevel(HttpLoggingInterceptor.Level.BODY);

            OkHttpClient.Builder httpClient = new OkHttpClient.Builder();
            httpClient.connectTimeout(60, TimeUnit.SECONDS);
            httpClient.readTimeout(60, TimeUnit.SECONDS);
            httpClient.writeTimeout(60, TimeUnit.SECONDS);
            
            // Add connection pool to prevent resource leaks
            httpClient.connectionPool(new okhttp3.ConnectionPool(5, 5, TimeUnit.MINUTES));
            
            httpClient.addInterceptor(logging);
            
            // Add auth token interceptor
            httpClient.addInterceptor(chain -> {
                Request original = chain.request();
                String token = AuthManager.getInstance(context).getAuthToken();
                if (token != null && !token.isEmpty()) {
                    Request request = original.newBuilder()
                            .header("Authorization", "Bearer " + token)
                            .method(original.method(), original.body())
                            .build();
                    return chain.proceed(request);
                }
                Log.d("ApiClient", "No Authorization header added"); // Debug log for missing token
                return chain.proceed(original);
            });
            
            // Add token authenticator for automatic token refresh on 401
            httpClient.authenticator(new TokenAuthenticator(context));

            retrofit = new Retrofit.Builder()
                    .baseUrl(BASE_URL)
                    .addConverterFactory(GsonConverterFactory.create())
                    .client(httpClient.build())
                    .build();
        }
        return retrofit;
    }
}
