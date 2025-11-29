import 'package:dio/dio.dart';
import '../error/exceptions.dart';

/// Centralized API error handler for consistent error handling across all datasources
class ApiErrorHandler {
  /// Handle DioException and convert to custom exceptions
  static Never handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      throw const NetworkException('Connection timeout');
    } else if (e.type == DioExceptionType.connectionError) {
      throw const NetworkException('No internet connection');
    } else if (e.response != null) {
      throw ServerException(
        e.response?.data['message'] ?? 'Server error occurred',
      );
    } else {
      throw const ServerException('Failed to connect to server');
    }
  }

  /// Handle generic exceptions
  static Never handleGenericException(Object e) {
    if (e is UnauthorizedException ||
        e is ServerException ||
        e is NetworkException ||
        e is TemporaryPasswordException) {
      throw e;
    }
    throw ServerException('Unexpected error: ${e.toString()}');
  }

  /// Execute API call with standardized error handling
  static Future<T> executeApiCall<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } on DioException catch (e) {
      handleDioException(e);
    } catch (e) {
      handleGenericException(e);
    }
  }
}
