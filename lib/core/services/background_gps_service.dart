import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';
import '../../firebase_options.dart';
import '../constants/api_constants.dart';
import '../../features/home/domain/gps_scan_record.dart';

/// 🔄 Background GPS Tracking Service
/// 
/// Sử dụng WorkManager để chạy GPS tracking THỰC SỰ ở background
/// ngay cả khi app bị kill/terminated
/// 
/// Flow:
/// 1. WorkManager đánh thức app mỗi 15-30 phút (tuỳ config backend)
/// 2. Lấy GPS hiện tại
/// 3. Gửi về backend attendance service
/// 4. Backend validate và lưu presence_verification
/// 
/// NOTE: WorkManager được Android OS đảm bảo chạy ngay cả khi:
/// - App bị force stop
/// - Device restart (với RECEIVE_BOOT_COMPLETED permission)
/// - Battery optimization enabled
class BackgroundGpsService {
  static const String GPS_SYNC_TASK = "gps_sync_task";
  static const String PERIODIC_GPS_SYNC = "periodic_gps_sync";

  /// Initialize WorkManager
  /// 
  /// Đăng ký callback function để WorkManager gọi khi tới lúc sync GPS
  static Future<void> initialize() async {
    debugPrint('🔧 [BackgroundGPS] Initializing WorkManager...');
    
    // Register the background task callback
    // MUST be a top-level function or static method
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode, // Enable logs in debug mode
    );
    
    debugPrint('✅ [BackgroundGPS] WorkManager initialized');
  }

  /// Start periodic GPS sync
  /// 
  /// Đăng ký task chạy định kỳ mỗi 15-30 phút
  /// Backend sẽ check nếu employee đang trong ca làm việc
  static Future<void> startPeriodicSync({
    Duration frequency = const Duration(minutes: 30),
  }) async {
    try {
      debugPrint('🚀 [BackgroundGPS] Starting periodic GPS sync...');
      debugPrint('   Frequency: ${frequency.inMinutes} minutes');
      
      await Workmanager().registerPeriodicTask(
        PERIODIC_GPS_SYNC, // Unique task ID
        GPS_SYNC_TASK,     // Task name
        frequency: frequency,
        constraints: Constraints(
          networkType: NetworkType.connected, // Require internet
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(minutes: 5),
      );
      
      debugPrint('✅ [BackgroundGPS] Periodic GPS sync registered');
    } catch (e) {
      debugPrint('❌ [BackgroundGPS] Failed to register: $e');
    }
  }

  /// Stop periodic GPS sync
  static Future<void> stopPeriodicSync() async {
    try {
      debugPrint('🛑 [BackgroundGPS] Stopping periodic GPS sync...');
      await Workmanager().cancelByUniqueName(PERIODIC_GPS_SYNC);
      debugPrint('✅ [BackgroundGPS] Periodic GPS sync stopped');
    } catch (e) {
      debugPrint('❌ [BackgroundGPS] Failed to stop: $e');
    }
  }

  /// Cancel all background tasks
  static Future<void> cancelAll() async {
    try {
      debugPrint('🗑️ [BackgroundGPS] Cancelling all tasks...');
      await Workmanager().cancelAll();
      debugPrint('✅ [BackgroundGPS] All tasks cancelled');
    } catch (e) {
      debugPrint('❌ [BackgroundGPS] Failed to cancel: $e');
    }
  }

  /// Check if GPS sync is running
  static Future<bool> isSyncRunning() async {
    // WorkManager doesn't provide direct way to check
    // You can implement custom SharedPreferences flag if needed
    return true; // Placeholder
  }
}

/// 📍 Background Task Callback Dispatcher
/// 
/// MUST be a top-level function (không phải method trong class)
/// WorkManager sẽ gọi function này khi tới lúc chạy task
/// 
/// NOTE: Function này chạy trong isolate riêng biệt
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('\n' + '='*80);
    debugPrint('🔄 [BackgroundGPS] ========== TASK STARTED ==========');
    debugPrint('='*80);
    debugPrint('Task: $task');
    debugPrint('Input: $inputData');
    debugPrint('Time: ${DateTime.now().toIso8601String()}');
    
    try {
      // Execute GPS sync
      await _executeGpsSync();
      
      debugPrint('✅ [BackgroundGPS] Task completed successfully');
      return Future.value(true);
    } catch (e, stackTrace) {
      debugPrint('❌ [BackgroundGPS] Task failed: $e');
      debugPrint('StackTrace: $stackTrace');
      return Future.value(false);
    }
  });
}

/// Execute GPS sync logic
/// 
/// Step-by-step:
/// 1. Initialize dependencies (Firebase, Hive)
/// 2. Check GPS permission
/// 3. Get current location
/// 4. Send to backend
/// 5. Save local record
Future<void> _executeGpsSync() async {
  // 1. Initialize Firebase if needed
  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('🔥 [BackgroundGPS] Firebase initialized');
    } catch (e) {
      debugPrint('❌ [BackgroundGPS] Firebase init failed: $e');
      // Continue anyway - GPS sync doesn't need Firebase
    }
  }

  // 2. Initialize Hive for auth token
  try {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen('authBox')) {
      await Hive.openBox('authBox');
    }
    debugPrint('💾 [BackgroundGPS] Hive initialized');
  } catch (e) {
    debugPrint('❌ [BackgroundGPS] Hive init failed: $e');
    throw Exception('Cannot access auth tokens');
  }

  // 3. Get auth token
  final authBox = Hive.box('authBox');
  final accessToken = authBox.get('accessToken') as String?;
  
  if (accessToken == null || accessToken.isEmpty) {
    debugPrint('⚠️ [BackgroundGPS] No access token - user not logged in');
    return; // Skip this sync
  }

  // 4. Check GPS permission
  final permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied || 
      permission == LocationPermission.deniedForever) {
    debugPrint('⚠️ [BackgroundGPS] Location permission denied');
    return; // Skip this sync
  }

  // 5. Get current location
  Position? position;
  try {
    position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 15),
    );
    debugPrint('📍 [BackgroundGPS] Got location: ${position.latitude}, ${position.longitude}');
  } catch (e) {
    debugPrint('❌ [BackgroundGPS] Failed to get location: $e');
    return; // Skip this sync
  }

  // 6. Send to backend
  try {
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

    final response = await dio.post(
      '/api/v1/attendance/gps-check',
      data: {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'timestamp': position.timestamp?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'source': 'background_sync', // Để backend biết đây là background sync
      },
    );

    debugPrint('✅ [BackgroundGPS] Sent GPS to backend');
    debugPrint('   Status: ${response.statusCode}');
    debugPrint('   Response: ${jsonEncode(response.data)}');

    // 7. Save local record
    await _saveScanRecord(
      position: position,
      responseData: response.data,
    );

  } catch (e) {
    debugPrint('❌ [BackgroundGPS] Failed to send GPS: $e');
    
    // Save failed attempt locally
    await _saveScanRecord(
      position: position,
      error: e.toString(),
    );
  }
}

/// Save GPS scan record to local Hive storage
Future<void> _saveScanRecord({
  required Position position,
  dynamic responseData,
  String? error,
}) async {
  try {
    if (!Hive.isBoxOpen('gps_history')) {
      await Hive.openBox('gps_history');
    }
    final box = Hive.box('gps_history');

    final record = GpsScanRecord(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      timestamp: position.timestamp ?? DateTime.now(),
      source: 'background_sync',
      responseData: responseData is Map ? Map<String, dynamic>.from(responseData) : null,
      error: error,
    );

    await box.add(record.toJson());
    debugPrint('💾 [BackgroundGPS] Saved scan record');
  } catch (e) {
    debugPrint('❌ [BackgroundGPS] Failed to save record: $e');
  }
}
