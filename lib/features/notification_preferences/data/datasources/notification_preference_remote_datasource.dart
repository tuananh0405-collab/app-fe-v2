import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/notification_preference_model.dart';
import '../models/update_notification_preference_dto.dart';

abstract class NotificationPreferenceRemoteDataSource {
  Future<List<NotificationPreferenceModel>> getPreferences(int employeeId);
  Future<NotificationPreferenceModel> updatePreference(UpdateNotificationPreferenceDto dto);
}

class NotificationPreferenceRemoteDataSourceImpl
    implements NotificationPreferenceRemoteDataSource {
  final Dio dio;

  NotificationPreferenceRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<NotificationPreferenceModel>> getPreferences(int employeeId) async {
    try {
      final response = await dio.get(
        '/notification/notification-preferences',
        queryParameters: {'employeeId': employeeId},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Handle both direct array and wrapped response
        final List<dynamic> preferencesJson = data is List 
            ? data 
            : (data['data'] as List? ?? []);

        return preferencesJson
            .map((json) => NotificationPreferenceModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
          response.data['message'] ?? 'Unauthorized',
        );
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to load notification preferences',
        );
      }
    } on DioException catch (e) {
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
    } catch (e) {
      if (e is UnauthorizedException ||
          e is ServerException ||
          e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<NotificationPreferenceModel> updatePreference(
    UpdateNotificationPreferenceDto dto,
  ) async {
    try {
      final response = await dio.put(
        '/notification/notification-preferences',
        data: dto.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        // Handle wrapped response
        final preferenceJson = data is Map<String, dynamic> && data.containsKey('data')
            ? data['data']
            : data;

        return NotificationPreferenceModel.fromJson(preferenceJson as Map<String, dynamic>);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
          response.data['message'] ?? 'Unauthorized',
        );
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to update notification preference',
        );
      }
    } on DioException catch (e) {
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
    } catch (e) {
      if (e is UnauthorizedException ||
          e is ServerException ||
          e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }
}
