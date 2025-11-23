package com.example.flutter_application_1.attendance.data.service;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.os.Build;
import androidx.core.app.NotificationCompat;
import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.os.RemoteException;
import android.util.Log;
import androidx.annotation.Nullable;
import org.altbeacon.beacon.*;
import java.util.Collection;

public class BeaconScanService extends Service implements BeaconConsumer {
    private static final String TAG = "BeaconScanService";
    private static final String CHANNEL_ID = "BeaconScanServiceChannel";
    private static final int NOTIFICATION_ID = 123;
    private BeaconManager beaconManager;

    @Override
    public void onCreate() {
        super.onCreate();
        Log.d(TAG, "Creating BeaconScanService");
        
        createNotificationChannel();
        
        // Create the notification for the foreground service
        Intent notificationIntent = new Intent(this, com.example.flutter_application_1.MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 
                0, notificationIntent, PendingIntent.FLAG_IMMUTABLE);

        Notification notification = new NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("Attendance Service")
                .setContentText("Scanning for beacons...")
                .setSmallIcon(android.R.drawable.ic_dialog_info) // Use a system icon or app icon
                .setContentIntent(pendingIntent)
                .build();

        // Start as foreground service
        startForeground(NOTIFICATION_ID, notification);

        // Initialize BeaconManager
        beaconManager = BeaconManager.getInstanceForApplication(this);
        
        // Add iBeacon layout
        beaconManager.getBeaconParsers().clear();
        beaconManager.getBeaconParsers().add(new BeaconParser()
            .setBeaconLayout("m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24"));
            
        beaconManager.bind(this);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d(TAG, "BeaconScanService started command");
        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d(TAG, "BeaconScanService destroyed");
        beaconManager.unbind(this);
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onBeaconServiceConnect() {
        Log.d(TAG, "Beacon service connected");
        beaconManager.removeAllRangeNotifiers();
        beaconManager.addRangeNotifier(new RangeNotifier() {
            @Override
            public void didRangeBeaconsInRegion(Collection<Beacon> beacons, Region region) {
                if (beacons.size() > 0) {
                    Log.d(TAG, "Beacons found: " + beacons.size());
                    for (Beacon beacon : beacons) {
                        Log.d(TAG, "Beacon: " + beacon.toString() + " RSSI: " + beacon.getRssi());
                        // Broadcast beacon info
                        Intent intent = new Intent("com.example.flutter_application_1.BEACON_FOUND");
                        intent.putExtra("beaconUuid", beacon.getId1().toString());
                        intent.putExtra("beaconMajor", beacon.getId2().toInt());
                        intent.putExtra("beaconMinor", beacon.getId3().toInt());
                        intent.putExtra("rssi", beacon.getRssi());
                        intent.putExtra("distance", beacon.getDistance());
                        sendBroadcast(intent);
                    }
                }
            }
        });

        try {
            beaconManager.startRangingBeaconsInRegion(new Region("all-beacons", null, null, null));
            Log.d(TAG, "Started ranging beacons");
        } catch (RemoteException e) {
            Log.e(TAG, "Error starting ranging", e);
        }
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel serviceChannel = new NotificationChannel(
                    CHANNEL_ID,
                    "Beacon Scan Service Channel",
                    NotificationManager.IMPORTANCE_DEFAULT
            );
            NotificationManager manager = getSystemService(NotificationManager.class);
            if (manager != null) {
                manager.createNotificationChannel(serviceChannel);
            }
        }
    }
}
