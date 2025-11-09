enum NotificationType {
  attendanceReminder('ATTENDANCE_REMINDER'),
  checkInReminder('CHECK_IN_REMINDER'),
  checkOutReminder('CHECK_OUT_REMINDER'),
  leaveRequest('LEAVE_REQUEST'),
  leaveApproval('LEAVE_APPROVAL'),
  leaveRejection('LEAVE_REJECTION'),
  systemAnnouncement('SYSTEM_ANNOUNCEMENT'),
  other('OTHER');

  final String value;
  const NotificationType(this.value);

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationType.other,
    );
  }
}

enum NotificationPriority {
  low('LOW'),
  normal('NORMAL'),
  high('HIGH'),
  urgent('URGENT');

  final String value;
  const NotificationPriority(this.value);

  static NotificationPriority fromString(String value) {
    return NotificationPriority.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NotificationPriority.normal,
    );
  }
}

class NotificationEntity {
  final int id;
  final int recipientId;
  final String? recipientEmail;
  final String? recipientName;
  final String title;
  final String message;
  final NotificationType notificationType;
  final NotificationPriority priority;
  final String? relatedEntityType;
  final int? relatedEntityId;
  final Map<String, dynamic>? relatedData;
  final List<String> channels;
  final bool isRead;
  final DateTime? readAt;
  final bool emailSent;
  final DateTime? emailSentAt;
  final bool pushSent;
  final DateTime? pushSentAt;
  final bool smsSent;
  final DateTime? smsSentAt;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const NotificationEntity({
    required this.id,
    required this.recipientId,
    this.recipientEmail,
    this.recipientName,
    required this.title,
    required this.message,
    required this.notificationType,
    this.priority = NotificationPriority.normal,
    this.relatedEntityType,
    this.relatedEntityId,
    this.relatedData,
    required this.channels,
    this.isRead = false,
    this.readAt,
    this.emailSent = false,
    this.emailSentAt,
    this.pushSent = false,
    this.pushSentAt,
    this.smsSent = false,
    this.smsSentAt,
    this.metadata,
    required this.createdAt,
    this.expiresAt,
  });

  NotificationEntity copyWith({
    int? id,
    int? recipientId,
    String? recipientEmail,
    String? recipientName,
    String? title,
    String? message,
    NotificationType? notificationType,
    NotificationPriority? priority,
    String? relatedEntityType,
    int? relatedEntityId,
    Map<String, dynamic>? relatedData,
    List<String>? channels,
    bool? isRead,
    DateTime? readAt,
    bool? emailSent,
    DateTime? emailSentAt,
    bool? pushSent,
    DateTime? pushSentAt,
    bool? smsSent,
    DateTime? smsSentAt,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      recipientName: recipientName ?? this.recipientName,
      title: title ?? this.title,
      message: message ?? this.message,
      notificationType: notificationType ?? this.notificationType,
      priority: priority ?? this.priority,
      relatedEntityType: relatedEntityType ?? this.relatedEntityType,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      relatedData: relatedData ?? this.relatedData,
      channels: channels ?? this.channels,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      emailSent: emailSent ?? this.emailSent,
      emailSentAt: emailSentAt ?? this.emailSentAt,
      pushSent: pushSent ?? this.pushSent,
      pushSentAt: pushSentAt ?? this.pushSentAt,
      smsSent: smsSent ?? this.smsSent,
      smsSentAt: smsSentAt ?? this.smsSentAt,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
