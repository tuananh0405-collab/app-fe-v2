import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../constants/api_constants.dart';

class AuthInterceptor extends Interceptor {
  final Ref ref;

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
      final loginState = ref.read(loginControllerProvider);
      final refreshToken = loginState.refreshToken;

      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // Try to refresh token
          final newTokens = await _refreshToken(refreshToken);
          
          // Update tokens in state
          ref.read(loginControllerProvider.notifier).updateTokens(
            accessToken: newTokens['access_token'] as String,
            refreshToken: newTokens['refresh_token'] as String,
          );

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
          return handler.resolve(response);
        } catch (e) {
          // Refresh token failed, logout user
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

  Future<Map<String, dynamic>> _refreshToken(String refreshToken) async {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: ApiConstants.defaultHeaders,
    ));
    
    final response = await dio.post(
      '${ApiConstants.authBaseUrl}/refresh',
      data: {'refresh_token': refreshToken},
    );

    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map<String, dynamic> && data['access_token'] != null) {
        return {
          'access_token': data['access_token'],
          'refresh_token': data['refresh_token'] ?? refreshToken,
        };
      }
    }
    
    throw Exception('Failed to refresh token');
  }
}
