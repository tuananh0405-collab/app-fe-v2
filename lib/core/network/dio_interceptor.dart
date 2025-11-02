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
          
          final response = await Dio().fetch(options);
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
    final dio = Dio();
    final response = await dio.post(
      '${ApiConstants.baseUrl}/auth/refresh',
      data: {'refresh_token': refreshToken},
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return response.data['data'];
    } else {
      throw Exception('Failed to refresh token');
    }
  }
}
