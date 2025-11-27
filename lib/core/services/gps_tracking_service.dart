import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import '../utils/jwt_helper.dart';

/// GPS Tracking Service
/// 
/// Xử lý việc:
/// 1. Lấy GPS hiện tại
/// 2. Gửi GPS về attendance service
/// 3. Xử lý background GPS tracking khi nhận silent push
class GpsTrackingService {
  final Dio _dio;
  
  GpsTrackingService(this._dio);

  /// Check và request GPS permission
  Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('⚠️ Location services are disabled.');
      return false;
    }

    // Check current permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('⚠️ Location permissions are denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('⚠️ Location permissions are permanently denied');
      return false;
    }

    return true;
  }

  /// Lấy GPS hiện tại
  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await checkAndRequestPermission();
      if (!hasPermission) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      debugPrint('📍 Got location: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('❌ Error getting location: $e');
      return null;
    }
  }

  /// Gửi GPS check về attendance service
  /// 
  /// Được gọi khi:
  /// 1. Nhận silent push từ backend (cron trigger)
  /// 2. Manual check-in/check-out
  /// 
  /// Backend tự động:
  /// - Extract employee_id từ JWT token
  /// - Tìm shift hiện tại của employee
  /// - Validate GPS trong phạm vi geofence
  /// 
  /// Payload example (simplified):
  /// ```json
  /// {
  ///   "latitude": 10.762622,
  ///   "longitude": 106.660172,
  ///   "location_accuracy": 5.0
  /// }
  /// ```
  Future<bool> sendGpsToAttendanceService({
    required Position position,
  }) async {
    try {
      debugPrint('📤 Sending GPS to attendance service...');
      debugPrint('   Position: ${position.latitude}, ${position.longitude}');

      final response = await _dio.post(
        '/gps/check',
        data: {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'location_accuracy': position.accuracy,
        },
      );

      if (response.statusCode == 200) {
        debugPrint('✅ GPS sent successfully');
        debugPrint('   Response: ${response.data}');
        return true;
      } else {
        debugPrint('⚠️ GPS send failed with status: ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      debugPrint('❌ Error sending GPS: ${e.message}');
      if (e.response != null) {
        debugPrint('   Response data: ${e.response?.data}');
        debugPrint('   Status code: ${e.response?.statusCode}');
      }
      return false;
    } catch (e) {
      debugPrint('❌ Unexpected error sending GPS: $e');
      return false;
    }
  }

  /// Xử lý GPS check request từ silent push notification
  /// 
  /// Flow:
  /// 1. Backend gửi silent push với metadata.action = 'BACKGROUND_GPS_SYNC'
  /// 2. App wake background service
  /// 3. Lấy GPS hiện tại
  /// 4. Gửi về attendance service (backend tự extract employee_id và tìm shift)
  /// 
  /// Message data format:
  /// ```json
  /// {
  ///   "type": "GPS_CHECK_REQUEST",
  ///   "action": "BACKGROUND_GPS_SYNC",
  ///   "timestamp": "2025-11-27T10:00:00Z"
  /// }
  /// ```
  Future<void> handleGpsCheckRequest(Map<String, dynamic> data) async {
    try {
      debugPrint('📍 [GPS_CHECK] Received GPS check request');
      debugPrint('   Data: ${jsonEncode(data)}');

      // Extract metadata
      final type = data['type'] as String?;
      final action = data['action'] as String?;
      
      // Validate request
      if (type != 'GPS_CHECK_REQUEST' || action != 'BACKGROUND_GPS_SYNC') {
        debugPrint('⚠️ Invalid GPS check request type or action');
        return;
      }

      // Get current location
      final position = await getCurrentLocation();
      if (position == null) {
        debugPrint('⚠️ Could not get current location');
        return;
      }

      // Send GPS to attendance service
      // Backend will auto-extract employee_id from JWT token and find active shift
      await sendGpsToAttendanceService(
        position: position,
      );
    } catch (e) {
      debugPrint('❌ Error handling GPS check request: $e');
    }
  }

  /// Watch location changes (for real-time tracking)
  /// Optional: Để track liên tục trong ca làm việc
  Stream<Position> watchLocation() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );
  }
}
