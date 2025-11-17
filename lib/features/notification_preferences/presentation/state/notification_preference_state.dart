import '../../domain/models/notification_preference.dart';

enum NotificationPreferenceStatus {
  initial,
  loading,
  success,
  error,
}

class NotificationPreferenceState {
  final NotificationPreferenceStatus status;
  final List<NotificationPreference> preferences;
  final String? errorMessage;
  final bool isUpdating;

  const NotificationPreferenceState({
    this.status = NotificationPreferenceStatus.initial,
    this.preferences = const [],
    this.errorMessage,
    this.isUpdating = false,
  });

  NotificationPreferenceState copyWith({
    NotificationPreferenceStatus? status,
    List<NotificationPreference>? preferences,
    String? errorMessage,
    bool? isUpdating,
    bool clearError = false,
  }) {
    return NotificationPreferenceState(
      status: status ?? this.status,
      preferences: preferences ?? this.preferences,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}
