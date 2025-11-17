import '../models/notification_preference.dart';
import '../repositories/notification_preference_repository.dart';

class GetNotificationPreferencesUseCase {
  final NotificationPreferenceRepository repository;

  GetNotificationPreferencesUseCase(this.repository);

  Future<List<NotificationPreference>> call(int employeeId) {
    return repository.getPreferences(employeeId);
  }
}
