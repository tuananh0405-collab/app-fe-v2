import '../../domain/models/notification_preference.dart';
import '../../domain/models/notification_type.dart';
import '../../domain/repositories/notification_preference_repository.dart';
import '../datasources/notification_preference_remote_datasource.dart';
import '../models/update_notification_preference_dto.dart';

class NotificationPreferenceRepositoryImpl implements NotificationPreferenceRepository {
  final NotificationPreferenceRemoteDataSource remoteDataSource;

  NotificationPreferenceRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<List<NotificationPreference>> getPreferences(int employeeId) async {
    try {
      final preferences = await remoteDataSource.getPreferences(employeeId);
      return preferences;
    } catch (e) {
      throw Exception('Failed to get notification preferences: $e');
    }
  }

  @override
  Future<NotificationPreference?> getPreferenceByType(
    int employeeId,
    NotificationType notificationType,
  ) async {
    try {
      final preferences = await remoteDataSource.getPreferences(employeeId);
      return preferences
          .where((p) => p.notificationType == notificationType)
          .firstOrNull;
    } catch (e) {
      throw Exception('Failed to get notification preference: $e');
    }
  }

  @override
  Future<NotificationPreference> updatePreference(
    int employeeId,
    NotificationType notificationType, {
    bool? emailEnabled,
    bool? pushEnabled,
    bool? smsEnabled,
    bool? inAppEnabled,
    String? doNotDisturbStart,
    String? doNotDisturbEnd,
  }) async {
    try {
      final dto = UpdateNotificationPreferenceDto(
        employeeId: employeeId,
        notificationType: notificationType,
        emailEnabled: emailEnabled,
        pushEnabled: pushEnabled,
        smsEnabled: smsEnabled,
        inAppEnabled: inAppEnabled,
        doNotDisturbStart: doNotDisturbStart,
        doNotDisturbEnd: doNotDisturbEnd,
      );

      final preference = await remoteDataSource.updatePreference(dto);
      return preference;
    } catch (e) {
      throw Exception('Failed to update notification preference: $e');
    }
  }
}
