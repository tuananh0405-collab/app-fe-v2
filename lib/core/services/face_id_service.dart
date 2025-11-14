import 'package:flutter/services.dart';

/// Service for Face ID registration and verification
class FaceIdService {
  static const MethodChannel _channel =
      MethodChannel('com.example.flutter_application_1/faceid');

  /// Save user info to native SharedPreferences (for Face ID integration)
  /// 
  /// [userId] - The user ID
  /// [userName] - The user's full name (optional)
  /// [authToken] - The authentication token (optional)
  /// 
  /// Returns a Future that completes with true if successful
  static Future<bool> saveUserInfo({
    required String userId,
    String? userName,
    String? authToken,
  }) async {
    try {
      await _channel.invokeMethod('saveUserInfo', {
        'userId': userId,
        'userName': userName ?? '',
        'authToken': authToken ?? '',
      });
      return true;
    } on PlatformException catch (e) {
      print('Failed to save user info: ${e.message}');
      return false;
    }
  }

  /// Register Face ID for the given user
  /// 
  /// [userId] - The user ID to register Face ID for
  /// 
  /// Returns a Future that completes with true if successful
  static Future<bool> registerFaceId(String userId) async {
    try {
      final bool result = await _channel.invokeMethod('registerFaceId', {
        'userId': userId,
      });
      return result;
    } on PlatformException catch (e) {
      print('Failed to register Face ID: ${e.message}');
      return false;
    }
  }

  /// Verify Face ID for the given user
  /// 
  /// [userId] - The user ID to verify Face ID for
  /// 
  /// Returns a Future that completes with true if verification is successful
  static Future<bool> verifyFaceId(String userId) async {
    try {
      final bool result = await _channel.invokeMethod('verifyFaceId', {
        'userId': userId,
      });
      return result;
    } on PlatformException catch (e) {
      print('Failed to verify Face ID: ${e.message}');
      return false;
    }
  }

  /// Update Face ID for the given user
  /// 
  /// [userId] - The user ID to update Face ID for
  /// 
  /// Returns a Future that completes with true if update is successful
  static Future<bool> updateFaceId(String userId) async {
    try {
      final bool result = await _channel.invokeMethod('updateFaceId', {
        'userId': userId,
      });
      return result;
    } on PlatformException catch (e) {
      print('Failed to update Face ID: ${e.message}');
      return false;
    }
  }

  /// Set up a listener for Face ID registration results
  /// 
  /// [onResult] - Callback function that receives the registration result
  static void setFaceIdResultListener(Function(bool success) onResult) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onFaceIdRegistered') {
        final success = call.arguments['success'] as bool;
        onResult(success);
      }
    });
  }
}
