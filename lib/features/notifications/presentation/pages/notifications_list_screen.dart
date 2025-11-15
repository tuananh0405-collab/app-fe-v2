import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/bottom_navigation.dart';
import '../../../../flutter_flow/flutter_flow.dart';
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
    extends ConsumerState<NotificationsListScreen>
    with TickerProviderStateMixin, AnimationControllerMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    // Setup animations
    setupAnimations({
      'listItemOnPageLoad': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effects: FFAnimations.fadeInSlideUp(
          delay: const Duration(milliseconds: 0),
          duration: const Duration(milliseconds: 400),
        ),
      ),
    });
    
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
    final theme = FlutterFlowTheme.of(context);
    final state = ref.watch(notificationListControllerProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go(AppRoutePath.home);
        }
      },
      child: Scaffold(
        backgroundColor: theme.primaryBackground,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Thông báo',
                style: theme.title2.override(color: Colors.white),
              ),
              if (state.unreadCount > 0)
                Text(
                  '${state.unreadCount} chưa đọc',
                  style: theme.bodyText2.override(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.white70,
                  ),
                ),
            ],
          ),
          centerTitle: true,
          elevation: 2,
          backgroundColor: theme.primaryColor,
          leading: FFIconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go(AppRoutePath.home),
            buttonSize: 48,
          ),
          actions: [
            if (state.unreadCount > 0)
              TextButton(
                onPressed: () {
                  _showMarkAllAsReadDialog();
                },
                child: Text(
                  'Đọc tất cả',
                  style: theme.bodyText2.override(
                    color: Colors.white,
                    fontSize: 13,
                  ),
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
    final theme = FlutterFlowTheme.of(context);
    
    if (state.status == NotificationListStatus.loaded &&
        state.notifications.isEmpty) {
      return _buildEmptyState();
    }

    if (state.status == NotificationListStatus.loading) {
      return Center(
        child: FFLoadingIndicator(
          color: theme.primaryColor,
          size: 40,
        ),
      );
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
      color: theme.primaryColor,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.notifications.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.notifications.length) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: FFLoadingIndicator(
                  color: theme.primaryColor,
                  size: 30,
                ),
              ),
            );
          }

          final notification = state.notifications[index];
          return _NotificationCard(
            notification: notification,
            onTap: () => _handleNotificationTap(notification),
          ).animateOnPageLoad(animationsMap['listItemOnPageLoad']!);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = FlutterFlowTheme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: theme.secondaryText,
          ),
          const SizedBox(height: 16),
          Text(
            'Không có thông báo',
            style: theme.title2,
          ),
          const SizedBox(height: 8),
          Text(
            'Bạn đã xem hết tất cả!',
            style: theme.bodyText1.override(
              color: theme.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    final theme = FlutterFlowTheme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Lỗi tải thông báo',
            style: theme.title2,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: theme.bodyText1,
            ),
          ),
          const SizedBox(height: 24),
          FFButton(
            text: 'Thử lại',
            icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
            onPressed: () {
              ref
                  .read(notificationListControllerProvider.notifier)
                  .loadNotifications(refresh: true);
            },
            options: FFButtonOptions(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              color: theme.primaryColor,
              textStyle: theme.subtitle2.override(color: Colors.white),
              elevation: 2,
              borderRadius: BorderRadius.circular(8),
            ),
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
    final theme = FlutterFlowTheme.of(context);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.secondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Đánh dấu tất cả đã đọc',
          style: theme.title3,
        ),
        content: Text(
          'Bạn có chắc chắn muốn đánh dấu tất cả thông báo là đã đọc?',
          style: theme.bodyText1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Hủy',
              style: theme.bodyText2.override(color: theme.secondaryText),
            ),
          ),
          FFButton(
            text: 'Đồng ý',
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ref
                  .read(notificationListControllerProvider.notifier)
                  .markAllAsRead();
            },
            options: FFButtonOptions(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: theme.primaryColor,
              textStyle: theme.bodyText2.override(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              elevation: 0,
              borderRadius: BorderRadius.circular(8),
            ),
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
    final theme = FlutterFlowTheme.of(context);
    final timeAgo = _getTimeAgo(notification.createdAt);

    IconData icon;
    Color iconColor;

    switch (notification.notificationType) {
      case NotificationType.leaveApproval:
        icon = Icons.check_circle_outline;
        iconColor = theme.success;
        break;
      case NotificationType.leaveRejection:
        icon = Icons.cancel_outlined;
        iconColor = theme.error;
        break;
      case NotificationType.attendanceReminder:
      case NotificationType.checkInReminder:
      case NotificationType.checkOutReminder:
        icon = Icons.access_time;
        iconColor = theme.warning;
        break;
      case NotificationType.leaveRequest:
        icon = Icons.event_note;
        iconColor = theme.primaryColor;
        break;
      case NotificationType.systemAnnouncement:
        icon = Icons.campaign;
        iconColor = theme.tertiaryColor;
        break;
      default:
        icon = Icons.info_outline;
        iconColor = theme.secondaryText;
    }

    // Priority badge
    Color? priorityColor;
    if (notification.priority == NotificationPriority.urgent) {
      priorityColor = theme.error;
    } else if (notification.priority == NotificationPriority.high) {
      priorityColor = theme.warning;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead
              ? theme.alternate
              : theme.primaryColor.withValues(alpha: 0.3),
          width: notification.isRead ? 1 : 2,
        ),
        boxShadow: notification.isRead
            ? []
            : [
                BoxShadow(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
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
                  color: iconColor.withValues(alpha: 0.1),
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
                            style: theme.bodyText1.override(
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.bold,
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
                              color: priorityColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              notification.priority.value,
                              style: theme.bodyText2.override(
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
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.message,
                      style: theme.bodyText2.override(
                        color: theme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: theme.secondaryText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeAgo,
                          style: theme.bodyText2.override(
                            fontSize: 12,
                            color: theme.secondaryText,
                          ),
                        ),
                        if (notification.relatedEntityType != null) ...[
                          const Spacer(),
                          Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: theme.secondaryText,
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
