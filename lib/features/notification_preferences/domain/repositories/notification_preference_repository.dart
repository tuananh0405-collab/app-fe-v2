import '../models/notification_preference.dart';
import '../models/notification_type.dart';

abstract class NotificationPreferenceRepository {
  /// Get all notification preferences for an employee
  Future<List<NotificationPreference>> getPreferences(int employeeId);

  /// Get a specific notification preference by employee ID and type
  Future<NotificationPreference?> getPreferenceByType(
    int employeeId,
    NotificationType notificationType,
  );

  /// Update or create a notification preference
  Future<NotificationPreference> updatePreference(
    int employeeId,
    NotificationType notificationType, {
    bool? emailEnabled,
    bool? pushEnabled,
    bool? smsEnabled,
    bool? inAppEnabled,
    String? doNotDisturbStart,
    String? doNotDisturbEnd,
  });
}
