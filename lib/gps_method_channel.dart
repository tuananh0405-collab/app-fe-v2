import 'dart:async';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'core/services/gps_tracking_service.dart';
import 'core/constants/api_constants.dart';

/// GPS Method Channel Handler
/// 
/// Handles GPS check requests from native Android code
class GpsMethodChannel {
  static const MethodChannel _channel = MethodChannel('com.example.flutter_application_1/gps');
  static GpsTrackingService? _gpsTrackingService;

  static void init() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  static void setGpsTrackingService(GpsTrackingService service) {
    _gpsTrackingService = service;
  }

  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'handleGpsCheck') {
      final args = call.arguments as Map?;
      if (args != null) {
        final latitude = args['latitude'] as double?;
        final longitude = args['longitude'] as double?;
        final accuracy = args['accuracy'] as double?;

        if (latitude != null && longitude != null && accuracy != null) {
          try {
            // Create Position object from provided coordinates
            final position = Position(
              latitude: latitude,
              longitude: longitude,
              timestamp: DateTime.now(),
              accuracy: accuracy,
              altitude: 0.0,
              altitudeAccuracy: 0.0,
              heading: 0.0,
              headingAccuracy: 0.0,
              speed: 0.0,
              speedAccuracy: 0.0,
            );

            // Use the GPS tracking service to send GPS check
            if (_gpsTrackingService != null) {
              final success = await _gpsTrackingService!.sendGpsToAttendanceService(
                position: position,
              );
              
              if (success) {
                return true;
              } else {
                throw PlatformException(
                  code: 'GPS_CHECK_FAILED',
                  message: 'GPS location verification failed. Please ensure you are at the correct location.',
                );
              }
            } else {
              // Fallback: create a temporary service instance with a basic Dio client
              final dio = Dio(BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
              ));
              
              final tempService = GpsTrackingService(dio);
              final success = await tempService.sendGpsToAttendanceService(
                position: position,
              );
              
              if (success) {
                return true;
              } else {
                throw PlatformException(
                  code: 'GPS_CHECK_FAILED',
                  message: 'GPS location verification failed. Please ensure you are at the correct location.',
                );
              }
            }
          } catch (e) {
            throw PlatformException(
              code: 'GPS_CHECK_ERROR',
              message: e.toString(),
            );
          }
        } else {
          throw PlatformException(
            code: 'INVALID_ARGUMENT',
            message: 'latitude, longitude, and accuracy are required',
          );
        }
      }
    }
    return null;
  }
}
