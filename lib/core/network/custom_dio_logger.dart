import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Custom Dio Logger that only logs:
/// - Request method and URL
/// - Error responses with details
/// This prevents terminal overflow while still tracking API calls
class CustomDioLogger extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logRequest(options);
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logResponse(response);
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logError(err);
    super.onError(err, handler);
  }

  void _logRequest(RequestOptions options) {
    if (kDebugMode) {
      print('│ ===============> 🚀 REQUEST: ${options.method} ${options.uri}');
    }
  }

  void _logResponse(Response response) {
    if (kDebugMode) {
      final statusCode = response.statusCode;
      final emoji = (statusCode != null && statusCode >= 200 && statusCode < 300) 
          ? '✅' 
          : '⚠️';
      
      print('│ ===============> $emoji RESPONSE: $statusCode');
    }
  }

  void _logError(DioException err) {
    if (kDebugMode) {
      print('┌─────────────────────────────────────────────────────────────');
      print('│ ❌ ERROR: ${err.requestOptions.method} ${err.requestOptions.uri}');
      print('│ Type: ${err.type}');
      print('│ Status: ${err.response?.statusCode}');
      print('│ Message: ${err.message}');
      
      // Log response data if available (for debugging errors)
      if (err.response?.data != null) {
        print('│ Response Data: ${err.response?.data}');
      }
      
      print('└─────────────────────────────────────────────────────────────');
    }
  }
}
