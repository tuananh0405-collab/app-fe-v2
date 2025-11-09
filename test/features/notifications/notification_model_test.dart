import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/features/notifications/domain/models/notification_model.dart';
import 'package:flutter_application_1/features/notifications/data/models/notification_model.dart';

void main() {
  group('NotificationModel', () {
    test('should create NotificationModel from JSON', () {
      // Arrange
      final json = {
        'id': 1,
        'recipient_id': 123,
        'recipient_email': 'test@example.com',
        'recipient_name': 'Test User',
        'title': 'Test Notification',
        'message': 'This is a test message',
        'notification_type': 'LEAVE_APPROVAL',
        'priority': 'NORMAL',
        'related_entity_type': 'LEAVE_REQUEST',
        'related_entity_id': 456,
        'related_data': {'key': 'value'},
        'channels': ['IN_APP', 'EMAIL'],
        'is_read': false,
        'read_at': null,
        'email_sent': true,
        'email_sent_at': '2025-11-06T10:00:00Z',
        'push_sent': false,
        'push_sent_at': null,
        'sms_sent': false,
        'sms_sent_at': null,
        'metadata': {'source': 'test'},
        'created_at': '2025-11-06T09:00:00Z',
        'expires_at': null,
      };

      // Act
      final model = NotificationModel.fromJson(json);

      // Assert
      expect(model.id, 1);
      expect(model.recipientId, 123);
      expect(model.recipientEmail, 'test@example.com');
      expect(model.title, 'Test Notification');
      expect(model.message, 'This is a test message');
      expect(model.notificationType, NotificationType.leaveApproval);
      expect(model.priority, NotificationPriority.normal);
      expect(model.isRead, false);
      expect(model.channels.length, 2);
      expect(model.channels, contains('IN_APP'));
      expect(model.channels, contains('EMAIL'));
    });

    test('should convert NotificationModel to JSON', () {
      // Arrange
      final model = NotificationModel(
        id: 1,
        recipientId: 123,
        recipientEmail: 'test@example.com',
        recipientName: 'Test User',
        title: 'Test Notification',
        message: 'This is a test message',
        notificationType: NotificationType.leaveApproval,
        priority: NotificationPriority.high,
        channels: ['IN_APP'],
        createdAt: DateTime.parse('2025-11-06T09:00:00Z'),
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['id'], 1);
      expect(json['recipient_id'], 123);
      expect(json['title'], 'Test Notification');
      expect(json['notification_type'], 'LEAVE_APPROVAL');
      expect(json['priority'], 'HIGH');
      expect(json['is_read'], false);
    });

    test('should handle NotificationType enum correctly', () {
      expect(NotificationType.fromString('LEAVE_APPROVAL'),
          NotificationType.leaveApproval);
      expect(NotificationType.fromString('SYSTEM_ANNOUNCEMENT'),
          NotificationType.systemAnnouncement);
      expect(NotificationType.fromString('UNKNOWN'), NotificationType.other);
    });

    test('should handle NotificationPriority enum correctly', () {
      expect(NotificationPriority.fromString('HIGH'), NotificationPriority.high);
      expect(
          NotificationPriority.fromString('URGENT'), NotificationPriority.urgent);
      expect(NotificationPriority.fromString('UNKNOWN'),
          NotificationPriority.normal);
    });

    test('should copy notification with updated fields', () {
      // Arrange
      final original = NotificationEntity(
        id: 1,
        recipientId: 123,
        title: 'Original',
        message: 'Message',
        notificationType: NotificationType.leaveRequest,
        channels: ['IN_APP'],
        isRead: false,
        createdAt: DateTime.now(),
      );

      // Act
      final updated = original.copyWith(
        isRead: true,
        readAt: DateTime.now(),
      );

      // Assert
      expect(updated.id, original.id);
      expect(updated.title, original.title);
      expect(updated.isRead, true);
      expect(updated.readAt, isNotNull);
      expect(original.isRead, false); // Original unchanged
    });
  });
}
