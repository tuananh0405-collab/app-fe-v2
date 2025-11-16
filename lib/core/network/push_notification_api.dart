import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../error/failures.dart';
import '../models/push_token_model.dart';

class PushNotificationApi {
  final Dio _dio;

  PushNotificationApi(this._dio);

  /// Register push token
  Future<Either<Failure, PushTokenResponse>> registerPushToken(
    RegisterPushTokenDto dto,
  ) async {
    try {
      final response = await _dio.post(
        '/notification/push-tokens/register',
        data: dto.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(PushTokenResponse.fromJson(response.data));
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to register push token',
        ));
      }
    } on DioException catch (e) {
      debugPrint('-----------------------------------------------------------------------------------DioException in registerPushToken: ${e.type}, ${e.message}, ${e.error}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return Left(ServerFailure('Connection timeout'));
      } else if (e.type == DioExceptionType.badResponse) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Server error',
        ));
      } else {
        return Left(ServerFailure('----------------------------------------------------------------------Network error: ${e.message ?? e.type}'));
      }
    } catch (e) {
      debugPrint('Exception in registerPushToken: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Unregister push token
  Future<Either<Failure, void>> unregisterPushToken(
    UnregisterPushTokenDto dto,
  ) async {
    try {
      final response = await _dio.post(
        '/notification/push-tokens/unregister',
        data: dto.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return const Right(null);
      } else {
        return Left(ServerFailure(
          response.data['message'] ?? 'Failed to unregister push token',
        ));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return Left(ServerFailure('Connection timeout'));
      } else if (e.type == DioExceptionType.badResponse) {
        return Left(ServerFailure(
          e.response?.data['message'] ?? 'Server error',
        ));
      } else {
        return Left(ServerFailure('Network error'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
