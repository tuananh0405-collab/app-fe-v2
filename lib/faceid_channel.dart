import 'dart:async';

import 'package:flutter/services.dart';

/// Lightweight wrapper around the native Face ID MethodChannel.
///
/// Usage:
///   // initialize (typically once at app start)
///   FaceIdChannel.init();
///
///   // register callback (optional)
///   FaceIdChannel.setOnRegisteredListener((success) {
///     print('Face register result: $success');
///   });
///
///   // open native register screen
///   await FaceIdChannel.registerFace(userId: '123');
class FaceIdChannel {
  static const MethodChannel _channel = MethodChannel('com.example.flutter_application_1/faceid');

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

  static Function(bool)? _onRegisteredListener;
  static final StreamController<bool> _onRegisteredController = StreamController<bool>.broadcast();

  /// Set a one-off listener callback for registration result coming from native.
  static void setOnRegisteredListener(Function(bool) listener) {
    _onRegisteredListener = listener;
  }

  /// Stream you can listen to for registration results.
  static Stream<bool> get onRegistered => _onRegisteredController.stream;

  /// Dispose controllers if needed (not required for most apps)
  static void dispose() {
    _onRegisteredController.close();
    _onRegisteredListener = null;
  }
}
