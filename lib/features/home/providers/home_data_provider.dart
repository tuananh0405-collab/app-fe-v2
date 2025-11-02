import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/notification_model.dart';
import '../domain/models/shift_model.dart';
import '../domain/models/location_status_model.dart';

final latestNotificationsProvider = Provider<List<NotificationModel>>((ref) {
  return [
    NotificationModel(
      id: '1',
      title: 'Leave Request Approved',
      message: 'Your leave request for Dec 25-26 has been approved by manager.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      type: NotificationType.success,
    ),
    NotificationModel(
      id: '2',
      title: 'Overtime Request Pending',
      message: 'Your overtime request is waiting for approval.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: false,
      type: NotificationType.warning,
    ),
    NotificationModel(
      id: '3',
      title: 'Schedule Update',
      message: 'Your shift schedule for next week has been updated.',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      type: NotificationType.info,
    ),
    NotificationModel(
      id: '4',
      title: 'Monthly Report Available',
      message: 'Your attendance report for November is now available.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      type: NotificationType.info,
    ),
  ];
});

final currentShiftProvider = Provider<ShiftModel>((ref) {
  final now = DateTime.now();
  return ShiftModel(
    id: 'shift-1',
    name: 'Morning Shift',
    startTime: DateTime(now.year, now.month, now.day, 10, 0),
    endTime: DateTime(now.year, now.month, now.day, 12, 0),
    dayOfWeek: 'Saturday',
    status: ShiftStatus.inProgress,
  );
});

final locationStatusProvider = Provider<LocationStatusModel>((ref) {
  return const LocationStatusModel(
    isInsideWorkZone: true,
    locationName: 'Main Office',
    distance: 0,
    lastUpdate: null,
  );
});
