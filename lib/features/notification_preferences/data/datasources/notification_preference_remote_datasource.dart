import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
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
        '${ApiConstants.notificationBaseUrl}/notification/notification-preferences',
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
      } else {
        throw Exception('Failed to load notification preferences: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<NotificationPreferenceModel> updatePreference(
    UpdateNotificationPreferenceDto dto,
  ) async {
    try {
      final response = await dio.put(
        '${ApiConstants.notificationBaseUrl}/notification/notification-preferences',
        data: dto.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        
        // Handle wrapped response
        final preferenceJson = data is Map<String, dynamic> && data.containsKey('data')
            ? data['data']
            : data;

        return NotificationPreferenceModel.fromJson(preferenceJson as Map<String, dynamic>);
      } else {
        throw Exception('Failed to update notification preference: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}
