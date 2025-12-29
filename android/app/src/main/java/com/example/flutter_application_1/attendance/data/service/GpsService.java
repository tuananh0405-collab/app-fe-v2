package com.example.flutter_application_1.attendance.data.service;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.core.content.ContextCompat;

/**
 * Service for handling GPS location retrieval
 * Provides both last known location (fast) and fresh location (accurate)
 */
public class GPSService {
    private static final String TAG = "GPSService";
    private static final long LOCATION_TIMEOUT_MS = 10000; // 10 seconds
    
    private LocationManager locationManager;
    private boolean isRequestingLocation = false;
    
    /**
     * Callback interface for location updates
     */
    public interface LocationCallback {
        void onLocationReceived(Location location);
        void onLocationFailed(String reason);
    }
    
    /**
     * Get last known location (fast but may be stale)
     * 
     * @param context Application context
     * @return Last known location, or null if not available
     */
    public Location getCurrentLocation(Context context) {
        try {
            if (locationManager == null) {
                locationManager = (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
            }
            
            // Check permission
            if (ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED &&
                ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                Log.w(TAG, "⚠️ Location permission not granted");
                return null;
            }
            
            // Get last known location from GPS provider
            Location gpsLocation = locationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER);
            Location networkLocation = locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER);
            
            // Choose best location (GPS preferred over Network)
            if (gpsLocation != null && networkLocation != null) {
                return gpsLocation.getTime() > networkLocation.getTime() ? gpsLocation : networkLocation;
            } else if (gpsLocation != null) {
                return gpsLocation;
            } else if (networkLocation != null) {
                return networkLocation;
            }
            
            return null;
            
        } catch (Exception e) {
            Log.e(TAG, "❌ Error getting current location", e);
            return null;
        }
    }
    
    /**
     * Request fresh GPS location with timeout
     * This provides more accurate location than getLastKnownLocation()
     * 
     * @param context Application context
     * @param callback Callback for location result
     */
    public void requestFreshLocation(Context context, LocationCallback callback) {
        if (isRequestingLocation) {
            Log.w(TAG, "⚠️ Location request already in progress");
            callback.onLocationFailed("Location request already in progress");
            return;
        }
        
        try {
            if (locationManager == null) {
                locationManager = (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);
            }
            
            // Check permission
            if (ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED &&
                ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                Log.w(TAG, "⚠️ Location permission not granted");
                callback.onLocationFailed("Location permission not granted");
                return;
            }
            
            // Check if GPS is enabled
            boolean isGpsEnabled = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER);
            boolean isNetworkEnabled = locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER);
            
            if (!isGpsEnabled && !isNetworkEnabled) {
                Log.w(TAG, "⚠️ GPS and Network providers are disabled");
                // Fallback to last known location
                Location lastKnown = getCurrentLocation(context);
                if (lastKnown != null) {
                    callback.onLocationReceived(lastKnown);
                } else {
                    callback.onLocationFailed("GPS and Network providers are disabled");
                }
                return;
            }
            
            isRequestingLocation = true;
            
            // Create location listener
            LocationListener locationListener = new LocationListener() {
                @Override
                public void onLocationChanged(Location location) {
                    Log.d(TAG, "📍 Fresh location received: " + location.getLatitude() + ", " + location.getLongitude());
                    isRequestingLocation = false;
                    locationManager.removeUpdates(this);
                    callback.onLocationReceived(location);
                }
                
                @Override
                public void onStatusChanged(String provider, int status, Bundle extras) {}
                
                @Override
                public void onProviderEnabled(String provider) {}
                
                @Override
                public void onProviderDisabled(String provider) {}
            };
            
            // Request location updates
            String provider = isGpsEnabled ? LocationManager.GPS_PROVIDER : LocationManager.NETWORK_PROVIDER;
            locationManager.requestLocationUpdates(
                provider,
                0,      // minTime
                0,      // minDistance
                locationListener,
                Looper.getMainLooper()
            );
            
            // Set timeout
            new Handler(Looper.getMainLooper()).postDelayed(() -> {
                if (isRequestingLocation) {
                    Log.w(TAG, "⏱️ Location request timeout");
                    isRequestingLocation = false;
                    locationManager.removeUpdates(locationListener);
                    
                    // Fallback to last known location
                    Location lastKnown = getCurrentLocation(context);
                    if (lastKnown != null) {
                        Log.d(TAG, "📍 Using last known location as fallback");
                        callback.onLocationReceived(lastKnown);
                    } else {
                        callback.onLocationFailed("Location request timeout");
                    }
                }
            }, LOCATION_TIMEOUT_MS);
            
        } catch (Exception e) {
            Log.e(TAG, "❌ Error requesting fresh location", e);
            isRequestingLocation = false;
            callback.onLocationFailed("Error: " + e.getMessage());
        }
    }
    
    /**
     * Reset service state
     */
    public void reset() {
        isRequestingLocation = false;
        if (locationManager != null) {
            // Remove any pending location updates
            try {
                locationManager.removeUpdates(location -> {});
            } catch (Exception e) {
                // Ignore
            }
        }
    }
}
