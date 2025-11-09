import '../../domain/models/notification_model.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.recipientId,
    super.recipientEmail,
    super.recipientName,
    required super.title,
    required super.message,
    required super.notificationType,
    super.priority,
    super.relatedEntityType,
    super.relatedEntityId,
    super.relatedData,
    required super.channels,
    super.isRead,
    super.readAt,
    super.emailSent,
    super.emailSentAt,
    super.pushSent,
    super.pushSentAt,
    super.smsSent,
    super.smsSentAt,
    super.metadata,
    required super.createdAt,
    super.expiresAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      recipientId: json['recipientId'] as int,
      recipientEmail: json['recipientEmail'] as String?,
      recipientName: json['recipientName'] as String?,
      title: json['title'] as String,
      message: json['message'] as String,
      notificationType: NotificationType.fromString(
        json['notificationType'] as String,
      ),
      priority: NotificationPriority.fromString(
        json['priority'] as String? ?? 'NORMAL',
      ),
      relatedEntityType: json['relatedEntityType'] as String?,
      relatedEntityId: json['relatedEntityId'] as int?,
      relatedData: json['relatedData'] as Map<String, dynamic>?,
      channels: (json['channels'] as List<dynamic>)
          .map((e) {
            if (e is String) {
              return e;
            } else if (e is Map<String, dynamic>) {
              return e['type'] as String;
            }
            return 'UNKNOWN';
          })
          .toList(),
      isRead: json['isRead'] as bool? ?? false,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      emailSent: json['emailSent'] as bool? ?? false,
      emailSentAt: json['emailSentAt'] != null
          ? DateTime.parse(json['emailSentAt'] as String)
          : null,
      pushSent: json['pushSent'] as bool? ?? false,
      pushSentAt: json['pushSentAt'] != null
          ? DateTime.parse(json['pushSentAt'] as String)
          : null,
      smsSent: json['smsSent'] as bool? ?? false,
      smsSentAt: json['smsSentAt'] != null
          ? DateTime.parse(json['smsSentAt'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipient_id': recipientId,
      'recipient_email': recipientEmail,
      'recipient_name': recipientName,
      'title': title,
      'message': message,
      'notification_type': notificationType.value,
      'priority': priority.value,
      'related_entity_type': relatedEntityType,
      'related_entity_id': relatedEntityId,
      'related_data': relatedData,
      'channels': channels,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'email_sent': emailSent,
      'email_sent_at': emailSentAt?.toIso8601String(),
      'push_sent': pushSent,
      'push_sent_at': pushSentAt?.toIso8601String(),
      'sms_sent': smsSent,
      'sms_sent_at': smsSentAt?.toIso8601String(),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }
}
