import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/home/domain/gps_scan_record.dart';
// jwt_helper not used here

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
  /// - Tăng presence_verification_rounds_completed counter
  ///
  /// 🔧 FIX: Đổi endpoint thành đúng path của attendance service
  Future<bool> sendGpsToAttendanceService({
    required Position position,
  }) async {
    try {
      debugPrint('📤 Sending GPS to attendance service...');
      debugPrint('   Position: ${position.latitude}, ${position.longitude}');
      debugPrint('   Accuracy: ${position.accuracy}m');

      // 🔧 FIX: Gọi đúng endpoint của attendance service
      // Backend sẽ tự động:
      // 1. Extract employee_id từ JWT token
      // 2. Tìm shift đang active của employee
      // 3. Validate GPS có trong office radius không
      // 4. Tăng presence_verification_rounds_completed
      // 5. Gửi notification nếu GPS ngoài vùng
      final response = await _dio.post(
        '/attendance/gps/check',
        data: {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'location_accuracy': position.accuracy,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ GPS verification completed');
        debugPrint('===========> response: ${response}');

        await _saveScanRecord(GpsScanRecord(
                  timestamp: DateTime.now(),
                  success: true,
                  latitude: position.latitude,
                  longitude: position.longitude,
                  accuracy: position.accuracy,
                  statusCode: response.statusCode,
                  responseData: response.data is Map ? response.data.cast<String, dynamic>() : null,
                ));

        if (response.data['is_valid'] == true) {
          debugPrint('   ✅ GPS within office geofence');
        } else {
          debugPrint('   ⚠️ GPS outside office geofence: ${response.data['message']}');
        }

        return true;
      } else {
        debugPrint('⚠️ GPS verification failed with status: ${response.statusCode}');
        // Persist a failed scan record (server returned non-200)
        await _saveScanRecord(GpsScanRecord(
          timestamp: DateTime.now(),
          success: false,
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          statusCode: response.statusCode,
          responseData: response.data is Map ? response.data.cast<String, dynamic>() : null,
        ));
        return false;
      }
    } on DioException catch (e) {
      debugPrint('❌ Error sending GPS: ${e.message}');
      if (e.response != null) {
        debugPrint('   Response data: ${e.response?.data}');
        debugPrint('   Status code: ${e.response?.statusCode}');
      }
      // Persist a failure record with error
      await _saveScanRecord(GpsScanRecord(
        timestamp: DateTime.now(),
        success: false,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        statusCode: e.response?.statusCode,
        responseData: e.response?.data is Map ? (e.response?.data as Map).cast<String, dynamic>() : null,
        error: e.message,
      ));
      return false;
    } catch (e) {
      debugPrint('❌ Unexpected error sending GPS: $e');
      await _saveScanRecord(GpsScanRecord(
        timestamp: DateTime.now(),
        success: false,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        error: e.toString(),
      ));
      return false;
    }
  }

  Future<void> _saveScanRecord(GpsScanRecord record) async {
    try {
      if (!Hive.isBoxOpen('gps_history')) {
        await Hive.initFlutter();
        await Hive.openBox('gps_history');
      }
      final box = Hive.box('gps_history');
      await box.add(record.toJson());
      // debugPrint('💾 Saved GPS scan record: ${record.toJson()}');
    } catch (e) {
      debugPrint('❌ Failed to save GPS scan record: $e');
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
