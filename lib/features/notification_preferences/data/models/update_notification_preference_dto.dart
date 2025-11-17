import '../../domain/models/notification_type.dart';

class UpdateNotificationPreferenceDto {
  final int employeeId;
  final NotificationType notificationType;
  final bool? emailEnabled;
  final bool? pushEnabled;
  final bool? smsEnabled;
  final bool? inAppEnabled;
  final String? doNotDisturbStart;
  final String? doNotDisturbEnd;

  const UpdateNotificationPreferenceDto({
    required this.employeeId,
    required this.notificationType,
    this.emailEnabled,
    this.pushEnabled,
    this.smsEnabled,
    this.inAppEnabled,
    this.doNotDisturbStart,
    this.doNotDisturbEnd,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'employeeId': employeeId,
      'notificationType': notificationType.value,
    };

    if (emailEnabled != null) data['emailEnabled'] = emailEnabled;
    if (pushEnabled != null) data['pushEnabled'] = pushEnabled;
    if (smsEnabled != null) data['smsEnabled'] = smsEnabled;
    if (inAppEnabled != null) data['inAppEnabled'] = inAppEnabled;
    if (doNotDisturbStart != null) data['doNotDisturbStart'] = doNotDisturbStart;
    if (doNotDisturbEnd != null) data['doNotDisturbEnd'] = doNotDisturbEnd;

    return data;
  }
}
