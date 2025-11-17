import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../firebase_options.dart';

/// Background message handler - MUST be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (!e.toString().contains('already exists')) {
      rethrow;
    }
  }
  debugPrint('🌙 ===== BACKGROUND MESSAGE RECEIVED =====');
  debugPrint('🌙 Message ID: ${message.messageId}');
  debugPrint('🌙 Notification Title: ${message.notification?.title}');
  debugPrint('🌙 Notification Body: ${message.notification?.body}');
  debugPrint('🌙 Data: ${message.data}');
  debugPrint('🌙 ========================================');
}

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  
  String? _fcmToken;
  String? _deviceId;

  // Callback for when token is received
  Function(String token, String deviceId)? onTokenReceived;
  
  // Callback for when notification is tapped
  Function(RemoteMessage message)? onNotificationTapped;
  
  // Callback for when notification is received in foreground
  Function(RemoteMessage message)? onForegroundMessage;

  String? get fcmToken => _fcmToken;
  String? get deviceId => _deviceId;

  /// Initialize push notification service
  Future<void> initialize() async {
    try {
      debugPrint('🚀 ===== INITIALIZING PUSH NOTIFICATIONS =====');
      
      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Request permission
      final notificationSettings = await _requestPermission();
      debugPrint('📋 Notification permission status: ${notificationSettings.authorizationStatus}');
      
      if (notificationSettings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ User granted notification permission');
        
        // Initialize local notifications
        await _initializeLocalNotifications();
        debugPrint('✅ Local notifications initialized');
        
        // Get device ID
        _deviceId = await _getDeviceId();
        debugPrint('📱 Device ID: $_deviceId');
        
        // Get FCM token
        _fcmToken = await _firebaseMessaging.getToken();
        debugPrint('🔑 FCM Token: $_fcmToken');
        
        if (_fcmToken != null && _deviceId != null) {
          onTokenReceived?.call(_fcmToken!, _deviceId!);
        }
        
        // Listen to token refresh
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          debugPrint('🔄 FCM Token refreshed: $newToken');
          if (_deviceId != null) {
            onTokenReceived?.call(newToken, _deviceId!);
          }
        });
        
        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        debugPrint('👂 Listening for foreground messages');
        
        // Handle notification taps
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
        debugPrint('👂 Listening for notification taps');
        
        // Check if app was opened from a notification
        final initialMessage = await _firebaseMessaging.getInitialMessage();
        if (initialMessage != null) {
          debugPrint('🎯 App opened from notification');
          _handleNotificationTap(initialMessage);
        }
        
        debugPrint('🎉 ===== PUSH NOTIFICATIONS INITIALIZED SUCCESSFULLY =====');
      } else {
        debugPrint('❌ User declined or has not accepted notification permission');
      }
    } catch (e) {
      debugPrint('💥 Error initializing push notifications: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
    }
  }

  /// Request notification permission
  Future<NotificationSettings> _requestPermission() async {
    return await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  /// Initialize local notifications for Android
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTapped,
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
      );
      
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// Get unique device ID
  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; // Android ID
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown_ios_device';
    }
    
    return 'unknown_device';
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('🔔 ===== FOREGROUND MESSAGE RECEIVED =====');
    debugPrint('🔔 Message ID: ${message.messageId}');
    debugPrint('🔔 Notification Title: ${message.notification?.title}');
    debugPrint('🔔 Notification Body: ${message.notification?.body}');
    debugPrint('🔔 Data: ${message.data}');
    debugPrint('🔔 =======================================');
    
    // Call callback
    onForegroundMessage?.call(message);
    
    // Show local notification
    _showLocalNotification(message);
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) {
      debugPrint('⚠️ No notification payload, skipping local notification');
      return;
    }

    debugPrint('📢 Showing local notification: ${notification.title}');

    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('👆 ===== NOTIFICATION TAPPED =====');
    debugPrint('👆 Message ID: ${message.messageId}');
    debugPrint('👆 Data: ${message.data}');
    debugPrint('👆 ================================');
    onNotificationTapped?.call(message);
  }

  /// Handle local notification tap
  void _onLocalNotificationTapped(NotificationResponse response) {
    debugPrint('Local notification tapped: ${response.payload}');
    // Parse payload and handle accordingly
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic: $e');
    }
  }

  /// Delete FCM token
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      debugPrint('FCM token deleted');
    } catch (e) {
      debugPrint('Error deleting FCM token: $e');
    }
  }
}
