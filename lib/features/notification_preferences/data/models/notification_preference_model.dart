import '../../domain/models/notification_preference.dart';
import '../../domain/models/notification_type.dart';

class NotificationPreferenceModel extends NotificationPreference {
  const NotificationPreferenceModel({
    super.id,
    required super.employeeId,
    required super.notificationType,
    required super.emailEnabled,
    required super.pushEnabled,
    required super.smsEnabled,
    required super.inAppEnabled,
    super.doNotDisturbStart,
    super.doNotDisturbEnd,
    required super.createdAt,
    required super.updatedAt,
  });

  factory NotificationPreferenceModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferenceModel(
      id: json['id'] as int?,
      employeeId: json['employeeId'] as int,
      notificationType: NotificationType.fromString(json['notificationType'] as String),
      emailEnabled: json['emailEnabled'] as bool? ?? true,
      pushEnabled: json['pushEnabled'] as bool? ?? true,
      smsEnabled: json['smsEnabled'] as bool? ?? false,
      inAppEnabled: json['inAppEnabled'] as bool? ?? true,
      doNotDisturbStart: json['doNotDisturbStart'] as String?,
      doNotDisturbEnd: json['doNotDisturbEnd'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'employeeId': employeeId,
      'notificationType': notificationType.value,
      'emailEnabled': emailEnabled,
      'pushEnabled': pushEnabled,
      'smsEnabled': smsEnabled,
      'inAppEnabled': inAppEnabled,
      if (doNotDisturbStart != null) 'doNotDisturbStart': doNotDisturbStart,
      if (doNotDisturbEnd != null) 'doNotDisturbEnd': doNotDisturbEnd,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory NotificationPreferenceModel.fromDomain(NotificationPreference preference) {
    return NotificationPreferenceModel(
      id: preference.id,
      employeeId: preference.employeeId,
      notificationType: preference.notificationType,
      emailEnabled: preference.emailEnabled,
      pushEnabled: preference.pushEnabled,
      smsEnabled: preference.smsEnabled,
      inAppEnabled: preference.inAppEnabled,
      doNotDisturbStart: preference.doNotDisturbStart,
      doNotDisturbEnd: preference.doNotDisturbEnd,
      createdAt: preference.createdAt,
      updatedAt: preference.updatedAt,
    );
  }
}
