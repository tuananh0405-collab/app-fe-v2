import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/notification_type.dart';
import '../../domain/usecases/get_notification_preferences_usecase.dart';
import '../../domain/usecases/update_notification_preference_usecase.dart';
import '../../providers/notification_preference_providers.dart';
import '../state/notification_preference_state.dart';

class NotificationPreferenceController extends Notifier<NotificationPreferenceState> {
  late final GetNotificationPreferencesUseCase _getPreferencesUseCase;
  late final UpdateNotificationPreferenceUseCase _updatePreferenceUseCase;

  @override
  NotificationPreferenceState build() {
    _getPreferencesUseCase = ref.read(getNotificationPreferencesUseCaseProvider);
    _updatePreferenceUseCase = ref.read(updateNotificationPreferenceUseCaseProvider);
    return const NotificationPreferenceState();
  }

  /// Load notification preferences for an employee
  Future<void> loadPreferences(int employeeId) async {
    state = state.copyWith(
      status: NotificationPreferenceStatus.loading,
      clearError: true,
    );

    try {
      final preferences = await _getPreferencesUseCase(employeeId);
      state = state.copyWith(
        status: NotificationPreferenceStatus.success,
        preferences: preferences,
      );
    } catch (e) {
      state = state.copyWith(
        status: NotificationPreferenceStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Update a specific notification preference
  Future<void> updatePreference({
    required int employeeId,
    required NotificationType notificationType,
    bool? emailEnabled,
    bool? pushEnabled,
    bool? smsEnabled,
    bool? inAppEnabled,
    String? doNotDisturbStart,
    String? doNotDisturbEnd,
  }) async {
    state = state.copyWith(isUpdating: true, clearError: true);

    try {
      final updatedPreference = await _updatePreferenceUseCase(
        employeeId: employeeId,
        notificationType: notificationType,
        emailEnabled: emailEnabled,
        pushEnabled: pushEnabled,
        smsEnabled: smsEnabled,
        inAppEnabled: inAppEnabled,
        doNotDisturbStart: doNotDisturbStart,
        doNotDisturbEnd: doNotDisturbEnd,
      );

      // Update the preference in the list
      final updatedList = state.preferences.map((pref) {
        if (pref.notificationType == notificationType) {
          return updatedPreference;
        }
        return pref;
      }).toList();

      // If preference doesn't exist in list, add it
      if (!updatedList.any((p) => p.notificationType == notificationType)) {
        updatedList.add(updatedPreference);
      }

      state = state.copyWith(
        preferences: updatedList,
        isUpdating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// Toggle email notifications for a type
  Future<void> toggleEmail(int employeeId, NotificationType type, bool enabled) async {
    await updatePreference(
      employeeId: employeeId,
      notificationType: type,
      emailEnabled: enabled,
    );
  }

  /// Toggle push notifications for a type
  Future<void> togglePush(int employeeId, NotificationType type, bool enabled) async {
    await updatePreference(
      employeeId: employeeId,
      notificationType: type,
      pushEnabled: enabled,
    );
  }

  /// Toggle SMS notifications for a type
  Future<void> toggleSms(int employeeId, NotificationType type, bool enabled) async {
    await updatePreference(
      employeeId: employeeId,
      notificationType: type,
      smsEnabled: enabled,
    );
  }

  /// Toggle in-app notifications for a type
  Future<void> toggleInApp(int employeeId, NotificationType type, bool enabled) async {
    await updatePreference(
      employeeId: employeeId,
      notificationType: type,
      inAppEnabled: enabled,
    );
  }

  /// Set Do Not Disturb period
  Future<void> setDoNotDisturb(
    int employeeId,
    NotificationType type,
    String? startTime,
    String? endTime,
  ) async {
    await updatePreference(
      employeeId: employeeId,
      notificationType: type,
      doNotDisturbStart: startTime,
      doNotDisturbEnd: endTime,
    );
  }
}
