import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/bottom_navigation.dart';
import '../../domain/models/notification_model.dart';
import '../../providers/notification_providers.dart';
import '../state/notification_list_state.dart';

class NotificationsListScreen extends ConsumerStatefulWidget {
  const NotificationsListScreen({super.key});

  @override
  ConsumerState<NotificationsListScreen> createState() =>
      _NotificationsListScreenState();
}

class _NotificationsListScreenState
    extends ConsumerState<NotificationsListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load notifications on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationListControllerProvider.notifier).loadNotifications();
    });

    // Setup pagination listener
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(notificationListControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationListControllerProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go(AppRoutePath.home);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Thông báo'),
              if (state.unreadCount > 0)
                Text(
                  '${state.unreadCount} chưa đọc',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
            ],
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(AppRoutePath.home),
          ),
          actions: [
            if (state.unreadCount > 0)
              TextButton(
                onPressed: () {
                  _showMarkAllAsReadDialog();
                },
                child: const Text(
                  'Đọc tất cả',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
          ],
        ),
        body: _buildBody(state),
        bottomNavigationBar: const BottomNavigation(currentIndex: 2),
      ),
    );
  }

  Widget _buildBody(NotificationListState state) {
    if (state.status == NotificationListStatus.loaded &&
        state.notifications.isEmpty) {
      return _buildEmptyState();
    }

    if (state.status == NotificationListStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == NotificationListStatus.error) {
      return _buildError(state.errorMessage ?? 'Có lỗi xảy ra');
    }

    if (state.notifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(notificationListControllerProvider.notifier)
            .loadNotifications(refresh: true);
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.notifications.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.notifications.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final notification = state.notifications[index];
          return _NotificationCard(
            notification: notification,
            onTap: () => _handleNotificationTap(notification),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Không có thông báo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Bạn đã xem hết tất cả!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Lỗi tải thông báo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref
                  .read(notificationListControllerProvider.notifier)
                  .loadNotifications(refresh: true);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(NotificationEntity notification) {
    if (!notification.isRead) {
      ref
          .read(notificationListControllerProvider.notifier)
          .markAsRead(notification.id);
    }

    // Navigate based on related entity type
    if (notification.relatedEntityType != null && 
        notification.relatedEntityId != null) {
      // You can implement navigation based on entity type
      // For example:
      // if (notification.relatedEntityType == 'LEAVE_REQUEST') {
      //   context.push('/leave-requests/${notification.relatedEntityId}');
      // }
    }
  }

  void _showMarkAllAsReadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đánh dấu tất cả đã đọc'),
        content: const Text(
          'Bạn có chắc chắn muốn đánh dấu tất cả thông báo là đã đọc?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(notificationListControllerProvider.notifier)
                  .markAllAsRead();
            },
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final timeAgo = _getTimeAgo(notification.createdAt);

    IconData icon;
    Color iconColor;

    switch (notification.notificationType) {
      case NotificationType.leaveApproval:
        icon = Icons.check_circle_outline;
        iconColor = Colors.green;
        break;
      case NotificationType.leaveRejection:
        icon = Icons.cancel_outlined;
        iconColor = Colors.red;
        break;
      case NotificationType.attendanceReminder:
      case NotificationType.checkInReminder:
      case NotificationType.checkOutReminder:
        icon = Icons.access_time;
        iconColor = Colors.orange;
        break;
      case NotificationType.leaveRequest:
        icon = Icons.event_note;
        iconColor = Colors.blue;
        break;
      case NotificationType.systemAnnouncement:
        icon = Icons.campaign;
        iconColor = Colors.purple;
        break;
      default:
        icon = Icons.info_outline;
        iconColor = Colors.grey;
    }

    // Priority badge
    Color? priorityColor;
    if (notification.priority == NotificationPriority.urgent) {
      priorityColor = Colors.red;
    } else if (notification.priority == NotificationPriority.high) {
      priorityColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: notification.isRead ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: notification.isRead
              ? Colors.grey.shade200
              : Theme.of(context).primaryColor.withOpacity(0.2),
          width: notification.isRead ? 1 : 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (priorityColor != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: priorityColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              notification.priority.value,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: priorityColor,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.message,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (notification.relatedEntityType != null) ...[
                          const Spacer(),
                          Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: Colors.grey[400],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return DateFormat('dd/MM/yyyy').format(timestamp);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}
