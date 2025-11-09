import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/paginated_notifications_model.dart';

abstract class NotificationRemoteDataSource {
  Future<PaginatedNotificationsModel> getNotifications({
    required int limit,
    required int offset,
    bool unreadOnly = false,
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
  }) async {
    try {
      final response = await dio.get(
        '${ApiConstants.notificationBaseUrl}/notification',
        queryParameters: {
          'limit': limit,
          'offset': offset,
          'unreadOnly': unreadOnly,
        },
        options: Options(
          headers: ApiConstants.defaultHeaders,
          validateStatus: (status) => status! < 500,
        ),
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
      throw NetworkException(e.message ?? 'Network error occurred');
    }
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    try {
      final response = await dio.put(
        '${ApiConstants.notificationBaseUrl}/notification/$notificationId/read',
        options: Options(
          headers: ApiConstants.defaultHeaders,
          validateStatus: (status) => status! < 500,
        ),
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
      throw NetworkException(e.message ?? 'Network error occurred');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final response = await dio.put(
        '${ApiConstants.notificationBaseUrl}/notification/read-all',
        options: Options(
          headers: ApiConstants.defaultHeaders,
          validateStatus: (status) => status! < 500,
        ),
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
      throw NetworkException(e.message ?? 'Network error occurred');
    }
  }
}
