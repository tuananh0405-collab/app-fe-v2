import 'package:flutter/foundation.dart';

class GpsScanRecord {
  final DateTime timestamp;
  final bool success;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final int? statusCode;
  final Map<String, dynamic>? responseData;
  final String? error;

  GpsScanRecord({
    required this.timestamp,
    required this.success,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.statusCode,
    this.responseData,
    this.error,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'success': success,
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'statusCode': statusCode,
        'responseData': responseData,
        'error': error,
      };

  static GpsScanRecord fromJson(Map<dynamic, dynamic> json) {
    return GpsScanRecord(
      timestamp: DateTime.parse(json['timestamp'] as String),
      success: json['success'] as bool,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      statusCode: json['statusCode'] as int?,
      responseData: (json['responseData'] as Map?)?.cast<String, dynamic>(),
      error: json['error'] as String?,
    );
  }

  @override
  String toString() {
    return 'GpsScanRecord{timestamp: $timestamp, success: $success, lat: $latitude, lon: $longitude, accuracy: $accuracy, statusCode: $statusCode, error: $error}';
  }
}
