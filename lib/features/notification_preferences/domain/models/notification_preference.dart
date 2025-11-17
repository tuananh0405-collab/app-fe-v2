import 'notification_type.dart';

class NotificationPreference {
  final int? id;
  final int employeeId;
  final NotificationType notificationType;
  final bool emailEnabled;
  final bool pushEnabled;
  final bool smsEnabled;
  final bool inAppEnabled;
  final String? doNotDisturbStart; // HH:mm format
  final String? doNotDisturbEnd; // HH:mm format
  final DateTime createdAt;
  final DateTime updatedAt;

  const NotificationPreference({
    this.id,
    required this.employeeId,
    required this.notificationType,
    this.emailEnabled = true,
    this.pushEnabled = true,
    this.smsEnabled = false,
    this.inAppEnabled = true,
    this.doNotDisturbStart,
    this.doNotDisturbEnd,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if current time is in Do Not Disturb period
  bool isInDoNotDisturbPeriod() {
    if (doNotDisturbStart == null || doNotDisturbEnd == null) return false;

    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return currentTime.compareTo(doNotDisturbStart!) >= 0 &&
        currentTime.compareTo(doNotDisturbEnd!) <= 0;
  }

  /// Create a copy with updated fields
  NotificationPreference copyWith({
    int? id,
    int? employeeId,
    NotificationType? notificationType,
    bool? emailEnabled,
    bool? pushEnabled,
    bool? smsEnabled,
    bool? inAppEnabled,
    String? doNotDisturbStart,
    String? doNotDisturbEnd,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationPreference(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      notificationType: notificationType ?? this.notificationType,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      inAppEnabled: inAppEnabled ?? this.inAppEnabled,
      doNotDisturbStart: doNotDisturbStart ?? this.doNotDisturbStart,
      doNotDisturbEnd: doNotDisturbEnd ?? this.doNotDisturbEnd,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPreference &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          employeeId == other.employeeId &&
          notificationType == other.notificationType;

  @override
  int get hashCode => id.hashCode ^ employeeId.hashCode ^ notificationType.hashCode;
}
