import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../firebase_options.dart';
import '../constants/api_constants.dart';
import 'gps_tracking_service.dart';

/// Background message handler - MUST be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    // Initialize Firebase only if not already initialized
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    
    debugPrint('\n' + '='*80);
    debugPrint('📩 [BACKGROUND NOTIFICATION RECEIVED]');
    debugPrint('='*80);
    debugPrint('Message ID: ${message.messageId}');
    debugPrint('Sent Time: ${message.sentTime}');
    debugPrint('\n--- Notification ---');
    if (message.notification != null) {
      debugPrint('Title: ${message.notification!.title}');
      debugPrint('Body: ${message.notification!.body}');
      debugPrint('Android Channel ID: ${message.notification!.android?.channelId}');
    } else {
      debugPrint('No notification payload (data-only message)');
    }
    debugPrint('\n--- Data Payload ---');
    message.data.forEach((key, value) {
      debugPrint('  $key: $value (${value.runtimeType})');
    });
    
    // Check if this is a GPS check request (silent push)
    final messageType = message.data['type'] as String?;
    final silent = message.data['silent']?.toString(); // Convert to string for comparison
    final action = message.data['action'] as String?; // New: check action field
    
    debugPrint('\n--- Message Classification ---');
    debugPrint('Type: $messageType');
    debugPrint('Silent: $silent');
    debugPrint('Action: $action');
    
    // Check both old and new format
    final isGpsCheck = messageType == 'GPS_CHECK_REQUEST' && 
                       (silent == 'true' || silent == 'TRUE') &&
                       action == 'BACKGROUND_GPS_SYNC';
    
    if (isGpsCheck) {
      debugPrint('📍 [BACKGROUND] GPS check request detected - processing...');
      
      // Initialize Hive to get access token
      if (!Hive.isBoxOpen('auth')) {
        await Hive.initFlutter();
        await Hive.openBox('auth');
      }
      
      final authBox = Hive.box('auth');
      final accessToken = authBox.get('accessToken') as String?;
      
      if (accessToken == null || accessToken.isEmpty) {
        debugPrint('[BACKGROUND] No access token found - skipping GPS check');
        return;
      }
      
      // Create standalone Dio instance for background handler
      final dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            ...ApiConstants.defaultHeaders,
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
      
      // Handle GPS check request
      final gpsTrackingService = GpsTrackingService(dio);
      await gpsTrackingService.handleGpsCheckRequest(message.data);
      
      debugPrint('✅ [BACKGROUND] GPS check request processed');
    }
  } catch (e) {
    debugPrint('❌ [BACKGROUND] Error: $e');
  }
}

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  
  final bool soundEnabled;
  final bool vibrationEnabled;
  final GpsTrackingService? gpsTrackingService;
  
  String? _fcmToken;
  String? _deviceId;

  // Callback for when token is received
  Function(String token, String deviceId)? onTokenReceived;
  
  // Callback for when notification is tapped
  Function(RemoteMessage message)? onNotificationTapped;
  
  // Callback for when notification is received in foreground
  Function(RemoteMessage message)? onForegroundMessage;

  PushNotificationService({
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.gpsTrackingService,
  });

  String? get fcmToken => _fcmToken;
  String? get deviceId => _deviceId;

  /// Initialize push notification service
  Future<void> initialize() async {
    try {      
      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Request permission
      final notificationSettings = await _requestPermission();
      
      if (notificationSettings.authorizationStatus == AuthorizationStatus.authorized) {
        
        // Initialize local notifications
        await _initializeLocalNotifications();        
        // Get device ID
        _deviceId = await _getDeviceId();
        
        // Get FCM token
        _fcmToken = await _firebaseMessaging.getToken();
        
        if (_fcmToken != null && _deviceId != null) {
          onTokenReceived?.call(_fcmToken!, _deviceId!);
        }
        
        // Listen to token refresh
        _firebaseMessaging.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          if (_deviceId != null) {
            onTokenReceived?.call(newToken, _deviceId!);
          }
        });
        
        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        
        // Handle notification taps
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
        
        // Check if app was opened from a notification
        final initialMessage = await _firebaseMessaging.getInitialMessage();
        if (initialMessage != null) {
          _handleNotificationTap(initialMessage);
        }
      }
    } catch (e) {
      // Handle error silently or rethrow based on your needs
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
      final channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
        playSound: soundEnabled,
        enableVibration: vibrationEnabled,
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
    debugPrint('\n' + '='*80);
    debugPrint('📩 [FOREGROUND NOTIFICATION RECEIVED]');
    debugPrint('='*80);
    debugPrint('Message ID: ${message.messageId}');
    debugPrint('Sent Time: ${message.sentTime}');
    debugPrint('\n--- Notification ---');
    if (message.notification != null) {
      debugPrint('Title: ${message.notification!.title}');
      debugPrint('Body: ${message.notification!.body}');
      debugPrint('Android Channel ID: ${message.notification!.android?.channelId}');
      debugPrint('iOS Sound: ${message.notification!.apple?.sound}');
    } else {
      debugPrint('No notification payload (data-only message)');
    }
    debugPrint('\n--- Data Payload ---');
    message.data.forEach((key, value) {
      debugPrint('  $key: $value (${value.runtimeType})');
    });
    
    // Check if this is a GPS check request (silent push)
    final messageType = message.data['type'] as String?;
    final silent = message.data['silent'] as String?; // Note: silent comes as String from FCM metadata
    
    if (messageType == 'GPS_CHECK_REQUEST' && silent == 'true') {
      debugPrint('📍 [FOREGROUND] GPS check request detected - processing...');
      
      // Handle GPS check in foreground
      if (gpsTrackingService != null) {
        gpsTrackingService!.handleGpsCheckRequest(message.data);
      } else {
        debugPrint('GPS tracking service not available');
      }
      
      // Don't show notification for silent GPS requests
      return;
    }
    
    // Call callback for normal notifications
    onForegroundMessage?.call(message);
    
    // Show local notification for normal messages
    _showLocalNotification(message);
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) {
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      playSound: soundEnabled,
      enableVibration: vibrationEnabled,
    );
    
    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: soundEnabled,
    );
    
    final details = NotificationDetails(
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
    debugPrint('\n' + '='*80);
    debugPrint('👆 [NOTIFICATION TAPPED]');
    debugPrint('='*80);
    debugPrint('Message ID: ${message.messageId}');
    if (message.notification != null) {
      debugPrint('Title: ${message.notification!.title}');
      debugPrint('Body: ${message.notification!.body}');
    }
    debugPrint('\n--- Data Payload ---');
    message.data.forEach((key, value) {
      debugPrint('  $key: $value');
    });
    debugPrint('='*80 + '\n');
    
    onNotificationTapped?.call(message);
  }

  /// Handle local notification tap
  void _onLocalNotificationTapped(NotificationResponse response) {
    debugPrint('\n' + '='*80);
    debugPrint('👆 [LOCAL NOTIFICATION TAPPED]');
    debugPrint('='*80);
    debugPrint('Notification ID: ${response.id}');
    debugPrint('Action ID: ${response.actionId}');
    debugPrint('Input: ${response.input}');
    debugPrint('Payload: ${response.payload}');
    debugPrint('='*80 + '\n');
    // Parse payload and handle accordingly
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
    } catch (e) {
      // Handle error
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (e) {
      // Handle error
    }
  }

  /// Delete FCM token
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
    } catch (e) {
      // Handle error
    }
  }
}