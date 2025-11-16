import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/push_token_model.dart' as models;
import '../network/push_notification_api.dart';
import 'push_notification_service.dart';

/// Manager class to handle push notification logic and API calls
class PushNotificationManager {
  final PushNotificationService _notificationService;
  final PushNotificationApi _api;

  PushNotificationManager({
    required PushNotificationService notificationService,
    required PushNotificationApi api,
  })  : _notificationService = notificationService,
        _api = api;

  /// Initialize push notifications
  Future<void> initialize({
    Function(RemoteMessage)? onNotificationTapped,
    Function(RemoteMessage)? onForegroundMessage,
  }) async {
    // Set callbacks
    _notificationService.onNotificationTapped = onNotificationTapped;
    _notificationService.onForegroundMessage = onForegroundMessage;
    
    // Set token received callback to register with backend
    _notificationService.onTokenReceived = _registerTokenWithBackend;
    
    // Initialize service
    await _notificationService.initialize();
  }

  /// Register token with backend
  Future<void> _registerTokenWithBackend(String token, String deviceId) async {
    try {
      final platform = _getPlatform();
      
      final dto = models.RegisterPushTokenDto(
        deviceId: deviceId,
        token: token,
        platform: platform,
      );
      
      final result = await _api.registerPushToken(dto);
      
      result.fold(
        (failure) => debugPrint('Failed to register push token: ${failure.message}'),
        (response) => debugPrint('Push token registered successfully: ${response.id}'),
      );
    } catch (e) {
      debugPrint('Error registering push token: $e');
    }
  }

  /// Manually register push token (if needed)
  Future<void> registerPushToken() async {
    final token = _notificationService.fcmToken;
    final deviceId = _notificationService.deviceId;
    
    if (token != null && deviceId != null) {
      await _registerTokenWithBackend(token, deviceId);
    } else {
      debugPrint('FCM token or device ID not available');
    }
  }

  /// Unregister push token
  Future<void> unregisterPushToken() async {
    try {
      final deviceId = _notificationService.deviceId;
      final token = _notificationService.fcmToken;
      
      if (deviceId == null && token == null) {
        debugPrint('No device ID or token to unregister');
        return;
      }
      
      final dto = models.UnregisterPushTokenDto(
        deviceId: deviceId,
        token: token,
      );
      
      final result = await _api.unregisterPushToken(dto);
      
      result.fold(
        (failure) => debugPrint('Failed to unregister push token: ${failure.message}'),
        (_) {
          debugPrint('Push token unregistered successfully');
          // Delete local token
          _notificationService.deleteToken();
        },
      );
    } catch (e) {
      debugPrint('Error unregistering push token: $e');
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _notificationService.subscribeToTopic(topic);
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _notificationService.unsubscribeFromTopic(topic);
  }

  /// Get current platform
  models.Platform _getPlatform() {
    if (Platform.isIOS) {
      return models.Platform.ios;
    } else if (Platform.isAndroid) {
      return models.Platform.android;
    } else {
      return models.Platform.web;
    }
  }

  /// Get FCM token
  String? get fcmToken => _notificationService.fcmToken;

  /// Get device ID
  String? get deviceId => _notificationService.deviceId;
}
