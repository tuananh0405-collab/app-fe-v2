import '../models/notification_preference.dart';
import '../models/notification_type.dart';
import '../repositories/notification_preference_repository.dart';

class UpdateNotificationPreferenceUseCase {
  final NotificationPreferenceRepository repository;

  UpdateNotificationPreferenceUseCase(this.repository);

  Future<NotificationPreference> call({
    required int employeeId,
    required NotificationType notificationType,
    bool? emailEnabled,
    bool? pushEnabled,
    bool? smsEnabled,
    bool? inAppEnabled,
    String? doNotDisturbStart,
    String? doNotDisturbEnd,
  }) {
    return repository.updatePreference(
      employeeId,
      notificationType,
      emailEnabled: emailEnabled,
      pushEnabled: pushEnabled,
      smsEnabled: smsEnabled,
      inAppEnabled: inAppEnabled,
      doNotDisturbStart: doNotDisturbStart,
      doNotDisturbEnd: doNotDisturbEnd,
    );
  }
}
