import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/paginated_notifications_model.dart';

abstract class NotificationRemoteDataSource {
  Future<PaginatedNotificationsModel> getNotifications({
    required int limit,
    required int offset,
    bool unreadOnly = false,
    String channelFilter = 'IN_APP',
  });
  
  Future<void> markAsRead(int notificationId);
  
  Future<void> markAllAsRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio dio;

  NotificationRemoteDataSourceImpl({required this.dio});

  @override
  Future<PaginatedNotificationsModel> getNotifications({
    required int limit,
    required int offset,
    bool unreadOnly = false,
    String channelFilter = 'IN_APP',
  }) async {
    try {
      final response = await dio.get(
        '/notification',
        queryParameters: {
          'limit': limit,
          'offset': offset,
          'unreadOnly': unreadOnly,
          'channelFilter': channelFilter,
        },
      );

      if (response.statusCode == 200) {
        return PaginatedNotificationsModel.fromJson(response.data);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
          response.data['message'] ?? 'Unauthorized',
        );
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to fetch notifications',
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
  Future<void> markAsRead(int notificationId) async {
    try {
      final response = await dio.put(
        '/notification/$notificationId/read',
      );

      if (response.statusCode == 401) {
        throw UnauthorizedException(
          response.data['message'] ?? 'Unauthorized',
        );
      } else if (response.statusCode != 200) {
        throw ServerException(
          response.data['message'] ?? 'Failed to mark as read',
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
  Future<void> markAllAsRead() async {
    try {
      final response = await dio.put(
        '/notification/read-all',
      );

      if (response.statusCode == 401) {
        throw UnauthorizedException(
          response.data['message'] ?? 'Unauthorized',
        );
      } else if (response.statusCode != 200) {
        throw ServerException(
          response.data['message'] ?? 'Failed to mark all as read',
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
