import 'dart:async';

import 'package:flutter/services.dart';

/// Lightweight wrapper around the native Face ID MethodChannel.
/// 
/// Handles communication between Flutter and native Android Face ID functionality.
/// Supports registration, success callbacks, and error handling.
class FaceIdChannel {
  static const MethodChannel _channel = MethodChannel('com.example.flutter_application_1/faceid');

  static Function(bool)? _onRegisteredListener;
  static final StreamController<bool> _onRegisteredController = StreamController<bool>.broadcast();

  static Function(String errorType, String message)? _onErrorListener;
  static final StreamController<Map<String, dynamic>> _onErrorController = StreamController<Map<String, dynamic>>.broadcast();

  static Function(Map<String, dynamic>)? _onSuccessListener;
  static final StreamController<Map<String, dynamic>> _onSuccessController = StreamController<Map<String, dynamic>>.broadcast();

  static void init() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'onFaceIdRegistered') {
      final args = call.arguments;
      final success = (args is Map && args['success'] == true) ? true : false;
      _onRegisteredController.add(success);
      if (_onRegisteredListener != null) {
        try {
          _onRegisteredListener!(success);
        } catch (_) {}
      }
    } else if (call.method == 'onFaceIdError') {
      final args = call.arguments as Map?;
      if (args != null) {
        final errorType = args['error'] as String?;
        final message = args['message'] as String?;
        _onErrorController.add({'error': errorType, 'message': message});
        if (_onErrorListener != null) {
          try {
            _onErrorListener!(errorType ?? 'UNKNOWN', message ?? 'Unknown error');
          } catch (_) {}
        }
      }
    } else if (call.method == 'onFaceIdSuccess') {
      final args = call.arguments as Map?;
      if (args != null) {
        final successData = Map<String, dynamic>.from(args);
        _onSuccessController.add(successData);
        if (_onSuccessListener != null) {
          try {
            _onSuccessListener!(successData);
          } catch (_) {}
        }
      }
    }
    return null;
  }

  /// Opens the native Face ID register screen. Returns true when the native call succeeded
  /// to start the activity (not the registration result itself).
  static Future<bool> registerFace({required String userId}) async {
    try {
      final res = await _channel.invokeMethod('registerFaceId', {'userId': userId});
      if (res is bool) return res;
      return true;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Set a one-off listener callback for registration result coming from native.
  static void setOnRegisteredListener(Function(bool) listener) {
    _onRegisteredListener = listener;
  }

  /// Set a listener callback for errors coming from native.
  static void setOnErrorListener(Function(String errorType, String message) listener) {
    _onErrorListener = listener;
  }

  /// Set a listener callback for success events coming from native.
  static void setOnSuccessListener(Function(Map<String, dynamic>) listener) {
    _onSuccessListener = listener;
  }

  /// Stream you can listen to for registration results.
  static Stream<bool> get onRegistered => _onRegisteredController.stream;

  /// Stream you can listen to for errors.
  static Stream<Map<String, dynamic>> get onError => _onErrorController.stream;

  /// Stream you can listen to for success events.
  static Stream<Map<String, dynamic>> get onSuccess => _onSuccessController.stream;

  /// Dispose controllers if needed (not required for most apps)
  static void dispose() {
    _onRegisteredController.close();
    _onErrorController.close();
    _onSuccessController.close();
    _onRegisteredListener = null;
    _onErrorListener = null;
    _onSuccessListener = null;
  }
}
