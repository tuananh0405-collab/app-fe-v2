import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/routes.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/providers/auth_providers.dart';
import '../../notifications/providers/notification_providers.dart';
import '../providers/home_data_provider.dart';
import '../domain/models/shift_model.dart';
import '../domain/models/location_status_model.dart';
import '../../notifications/domain/models/notification_model.dart';
import '../../../core/widgets/bottom_navigation.dart';
import '../../../flutter_flow/flutter_flow.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin, AnimationControllerMixin<HomeScreen> {
  
  @override
  void initState() {
    super.initState();
    
    // Setup animations
    setupAnimations({
      'headerOnPageLoad': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effects: FFAnimations.fadeInSlideUp(
          delay: const Duration(milliseconds: 0),
          duration: const Duration(milliseconds: 600),
        ),
      ),
      'cardOnPageLoad': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effects: FFAnimations.fadeInSlideUp(
          delay: const Duration(milliseconds: 100),
          duration: const Duration(milliseconds: 600),
        ),
      ),
    });
    
    // Load notifications when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationListControllerProvider.notifier).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final notificationState = ref.watch(notificationListControllerProvider);
    final currentShift = ref.watch(currentShiftProvider);
    final locationStatus = ref.watch(locationStatusProvider);
    final user = ref.watch(loginControllerProvider).user;

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        title: Text(
          'Home',
          style: theme.title2.override(color: Colors.white),
        ),
        backgroundColor: theme.primaryColor,
        elevation: 2,
        actions: [
          FFIconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () => context.push(AppRoutePath.notifications),
            buttonSize: 48,
          ),
          FFIconButton(
            icon: Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => context.push(AppRoutePath.settings),
            buttonSize: 48,
          ),
          FFIconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
            },
            buttonSize: 48,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(notificationListControllerProvider.notifier)
              .loadNotifications();
        },
        color: theme.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              _WelcomeHeader(userName: user?.fullName ?? 'User')
                  .animateOnPageLoad(animationsMap['headerOnPageLoad']!),
              const SizedBox(height: 24),

              // Latest Notifications
              _LatestNotificationsSection(
                notifications: notificationState.notifications.take(3).toList(),
              ).animateOnPageLoad(animationsMap['cardOnPageLoad']!),
              const SizedBox(height: 24),


              // Location Status
              _LocationStatusCard(locationStatus: locationStatus)
                  .animateOnPageLoad(animationsMap['cardOnPageLoad']!),
              const SizedBox(height: 16),

              // Current Shift
              _CurrentShiftCard(shift: currentShift)
                  .animateOnPageLoad(animationsMap['cardOnPageLoad']!),
              const SizedBox(height: 24),


              // Quick Actions
              const _QuickActionsSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 0),
    );
  }
}

class _WelcomeHeader extends ConsumerWidget {
  final String userName;

  const _WelcomeHeader({required this.userName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = FlutterFlowTheme.of(context);
    final hour = DateTime.now().hour;
    String greeting;
    Icon greetingIcon;
    
    if (hour < 12) {
      greeting = 'Good Morning';
      greetingIcon = Icon(Icons.wb_sunny, color: theme.warning);
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
      greetingIcon = Icon(Icons.light_mode, color: theme.warning);
    } else {
      greeting = 'Good Evening';
      greetingIcon = Icon(Icons.nights_stay, color: theme.primaryColor);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: greetingIcon,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: theme.bodyText2,
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: theme.title3.override(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationStatusCard extends StatelessWidget {
  final LocationStatusModel locationStatus;

  const _LocationStatusCard({required this.locationStatus});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final statusColor =
        locationStatus.isInsideWorkZone ? theme.success : theme.warning;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor,
            Color.lerp(statusColor, Colors.black, 0.2)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              locationStatus.isInsideWorkZone
                  ? Icons.check_circle_outline
                  : Icons.location_on_outlined,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location Status',
                  style: theme.bodyText2.override(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  locationStatus.statusText,
                  style: theme.subtitle1.override(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (locationStatus.locationName.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    locationStatus.locationName,
                    style: theme.bodyText2.override(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentShiftCard extends StatelessWidget {
  final ShiftModel shift;

  const _CurrentShiftCard({required this.shift});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final statusColor = shift.status == ShiftStatus.inProgress
        ? theme.info
        : shift.status == ShiftStatus.upcoming
            ? theme.warning
            : theme.secondaryText;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.primaryText.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Current Shift',
                style: theme.subtitle1.override(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  shift.status == ShiftStatus.inProgress
                      ? 'In Progress'
                      : shift.status == ShiftStatus.upcoming
                          ? 'Upcoming'
                          : 'Completed',
                  style: theme.bodyText2.override(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shift.name,
                      style: theme.title3.override(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${shift.dayOfWeek} • ${shift.timeRange}',
                      style: theme.bodyText2.override(
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LatestNotificationsSection extends ConsumerStatefulWidget {
  final List<NotificationEntity> notifications;

  const _LatestNotificationsSection({required this.notifications});

  @override
  ConsumerState<_LatestNotificationsSection> createState() =>
      _LatestNotificationsSectionState();
}

class _LatestNotificationsSectionState
    extends ConsumerState<_LatestNotificationsSection> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final notifications = widget.notifications;
    final notificationState = ref.watch(notificationListControllerProvider);
    final unreadCount = notificationState.unreadCount;

    if (notifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Latest Notifications',
                  style: theme.subtitle1.override(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$unreadCount',
                      style: theme.bodyText2.override(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            TextButton(
              onPressed: () => context.push(AppRoutePath.notifications),
              child: Text(
                'View All',
                style: theme.bodyText2.override(
                  color: theme.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _NotificationItem(notification: notifications[index]),
              );
            },
          ),
        ),
        if (notifications.length > 1) ...[
          const SizedBox(height: 12),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                notifications.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? theme.primaryColor
                        : theme.alternate,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationEntity notification;

  const _NotificationItem({required this.notification});

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
      case NotificationType.systemAnnouncement:
        icon = Icons.campaign_outlined;
        iconColor = theme.tertiaryColor;
        break;
      default:
        icon = Icons.info_outline;
        iconColor = theme.primaryColor;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            iconColor.withValues(alpha: 0.1),
            iconColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            offset: const Offset(0, 4),
            color: iconColor.withValues(alpha: 0.1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  notification.title,
                  style: theme.bodyText1.override(
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            notification.message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.bodyText2.override(
              color: theme.primaryText.withValues(alpha: 0.8),
            ).copyWith(height: 1.4),
          ),
          const SizedBox(height: 12),
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
              if (!notification.isRead) ...[
                const Spacer(),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }


  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    
    final actions = [
      {
        'icon': Icons.check_circle_outline,
        'label': 'Check In/Out',
        'color': theme.primaryColor,
        'path': AppRoutePath.attendanceCheck,
      },
      {
        'icon': Icons.calendar_today_outlined,
        'label': 'Leave Request',
        'color': theme.tertiaryColor,
        'path': AppRoutePath.leavesCreate,
      },
      {
        'icon': Icons.event_note,
        'label': 'My Leaves',
        'color': theme.success,
        'path': AppRoutePath.leaves,
      },
      {
        'icon': Icons.access_time,
        'label': 'Overtime',
        'color': theme.warning,
        'path': AppRoutePath.overtimesCreate,
      },
      {
        'icon': Icons.schedule_outlined,
        'label': 'Schedule',
        'color': theme.secondaryColor,
        'path': AppRoutePath.schedule,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.subtitle1.override(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            final actionColor = action['color'] as Color;
            
            return InkWell(
              onTap: () => context.push(action['path'] as String),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: actionColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: actionColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: actionColor.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      action['icon'] as IconData,
                      color: actionColor,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action['label'] as String,
                      style: theme.bodyText2.override(
                        color: actionColor,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

