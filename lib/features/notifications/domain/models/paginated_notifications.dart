import '../models/notification_model.dart';

class PaginatedNotifications {
  final List<NotificationEntity> notifications;
  final int total;
  final int unreadCount;
  final int limit;
  final int offset;
  final bool hasMore;

  const PaginatedNotifications({
    required this.notifications,
    required this.total,
    required this.unreadCount,
    required this.limit,
    required this.offset,
    required this.hasMore,
  });

  int get currentPage => (offset / limit).floor() + 1;
  int get totalPages => (total / limit).ceil();
}
