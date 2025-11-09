import '../../domain/models/paginated_notifications.dart';
import 'notification_model.dart';

class PaginatedNotificationsModel extends PaginatedNotifications {
  const PaginatedNotificationsModel({
    required super.notifications,
    required super.total,
    required super.unreadCount,
    required super.limit,
    required super.offset,
    required super.hasMore,
  });

  factory PaginatedNotificationsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    
    final notificationsList = (data['notifications'] as List)
        .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
        .toList();

    final total = data['total'] as int;
    final unreadCount = data['unreadCount'] as int;  // ✅ Sửa thành camelCase
    final limit = data['limit'] as int? ?? 20;  // ✅ Default value nếu không có
    final offset = data['offset'] as int? ?? 0;  // ✅ Default value nếu không có
    final hasMore = data['hasMore'] as bool? ?? false;  // ✅ Sử dụng hasMore từ API

    return PaginatedNotificationsModel(
      notifications: notificationsList,
      total: total,
      unreadCount: unreadCount,
      limit: limit,
      offset: offset,
      hasMore: hasMore,
    );
  }
}
