import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../constants/api_constants.dart';

class AuthInterceptor extends Interceptor {
  final Ref ref;
  bool _isRefreshing = false;
  final List<_PendingRequest> _pendingRequests = [];

  AuthInterceptor(this.ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Get access token from login state
    final loginState = ref.read(loginControllerProvider);
    final accessToken = loginState.accessToken;

    // Add token to headers if exists
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized - token expired
    if (err.response?.statusCode == 401) {
      // Skip refresh for auth endpoints to avoid infinite loops
      if (err.requestOptions.path.contains('/auth/login') ||
          err.requestOptions.path.contains('/auth/refresh')) {
        return super.onError(err, handler);
      }

      final loginState = ref.read(loginControllerProvider);
      final refreshToken = loginState.refreshToken;

      if (refreshToken != null && refreshToken.isNotEmpty) {
        // If already refreshing, queue this request
        if (_isRefreshing) {
          return _queueRequest(err, handler);
        }

        _isRefreshing = true;

        try {
          // Try to refresh token
          final newTokens = await _refreshToken(refreshToken);
          
          // Update tokens in state
          ref.read(loginControllerProvider.notifier).updateTokens(
            accessToken: newTokens['access_token'] as String,
            refreshToken: newTokens['refresh_token'] as String,
          );

          // Process all pending requests
          _processPendingRequests(newTokens['access_token'] as String);
          
          // Retry the failed request with new token
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer ${newTokens['access_token']}';
          
          // Create a new Dio instance for retry to avoid interceptor loops
          final retryDio = Dio(BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            headers: ApiConstants.defaultHeaders,
          ));
          retryDio.options.headers['Authorization'] = 'Bearer ${newTokens['access_token']}';
          
          final response = await retryDio.fetch(options);
          _isRefreshing = false;
          return handler.resolve(response);
        } catch (e) {
          // Refresh token failed, logout user and reject all pending requests
          _isRefreshing = false;
          _rejectPendingRequests(err);
          ref.read(loginControllerProvider.notifier).reset();
          return handler.reject(err);
        }
      } else {
        // No refresh token, logout user
        ref.read(loginControllerProvider.notifier).reset();
      }
    }

    super.onError(err, handler);
  }

  void _queueRequest(DioException err, ErrorInterceptorHandler handler) {
    final completer = Completer<Response>();
    _pendingRequests.add(_PendingRequest(
      requestOptions: err.requestOptions,
      handler: handler,
      completer: completer,
    ));
  }

  void _processPendingRequests(String newAccessToken) {
    for (final pendingRequest in _pendingRequests) {
      final options = pendingRequest.requestOptions;
      options.headers['Authorization'] = 'Bearer $newAccessToken';
      
      final retryDio = Dio(BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: ApiConstants.defaultHeaders,
      ));
      retryDio.options.headers['Authorization'] = 'Bearer $newAccessToken';
      
      retryDio.fetch(options).then((response) {
        pendingRequest.handler.resolve(response);
      }).catchError((error) {
        pendingRequest.handler.reject(
          error is DioException ? error : DioException(
            requestOptions: options,
            error: error,
          ),
        );
      });
    }
    _pendingRequests.clear();
  }

  void _rejectPendingRequests(DioException err) {
    for (final pendingRequest in _pendingRequests) {
      pendingRequest.handler.reject(err);
    }
    _pendingRequests.clear();
  }

  Future<Map<String, dynamic>> _refreshToken(String refreshToken) async {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: ApiConstants.defaultHeaders,
    ));
    
    final response = await dio.post(
      ApiConstants.refreshTokenEndpoint,
      data: {'refresh_token': refreshToken},
    );

    if (response.statusCode == 200) {
      final responseData = response.data;
      
      // Handle ApiResponseModel wrapper
      Map<String, dynamic>? tokenData;
      if (responseData is Map<String, dynamic>) {
        if (responseData['data'] != null && responseData['data'] is Map<String, dynamic>) {
          // Response is wrapped in ApiResponseModel
          tokenData = responseData['data'] as Map<String, dynamic>;
        } else if (responseData['access_token'] != null) {
          // Response is direct
          tokenData = responseData;
        }
      }

      if (tokenData != null && tokenData['access_token'] != null) {
        return {
          'access_token': tokenData['access_token'] as String,
          'refresh_token': tokenData['refresh_token'] as String? ?? refreshToken,
        };
      }
    }
    
    throw Exception('Failed to refresh token: Invalid response format');
  }
}

class _PendingRequest {
  final RequestOptions requestOptions;
  final ErrorInterceptorHandler handler;
  final Completer<Response> completer;

  _PendingRequest({
    required this.requestOptions,
    required this.handler,
    required this.completer,
  });
}
