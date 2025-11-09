import '../../domain/models/notification_model.dart';

enum NotificationListStatus { initial, loading, loaded, loadingMore, error }

class NotificationListState {
  final NotificationListStatus status;
  final List<NotificationEntity> notifications;
  final int total;
  final int offset;
  final int limit;
  final bool hasMore;
  final String? errorMessage;
  final int unreadCount;

  const NotificationListState({
    this.status = NotificationListStatus.initial,
    this.notifications = const [],
    this.total = 0,
    this.offset = 0,
    this.limit = 20,
    this.hasMore = true,
    this.errorMessage,
    this.unreadCount = 0,
  });

  NotificationListState copyWith({
    NotificationListStatus? status,
    List<NotificationEntity>? notifications,
    int? total,
    int? offset,
    int? limit,
    bool? hasMore,
    String? errorMessage,
    int? unreadCount,
    bool clearError = false,
  }) {
    return NotificationListState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      total: total ?? this.total,
      offset: offset ?? this.offset,
      limit: limit ?? this.limit,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
