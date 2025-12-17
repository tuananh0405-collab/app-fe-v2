import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import 'dio_interceptor.dart';
import 'custom_dio_logger.dart';

class DioClient {
  final Ref ref;
  late final Dio _dio;

  DioClient(this.ref) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: ApiConstants.defaultHeaders,
        validateStatus: (status) => status != null && status >= 200 && status < 300,
      ),
    );

    // Add interceptors
    _dio.interceptors.addAll([
      AuthInterceptor(ref), // Auto add token
      CustomDioLogger(), // Lightweight logger - only logs URLs and errors
    ]);
  }

  Dio get dio => _dio;
}

// Provider for Dio instance
final dioProvider = Provider<Dio>((ref) {
  return DioClient(ref).dio;
});
