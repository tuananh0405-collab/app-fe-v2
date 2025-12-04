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

import '../../attendance/domain/entities/attendance_entity.dart' as attendance;
import '../../attendance/presentation/widgets/attendance_shift_item.dart';
import '../../attendance/providers/attendance_providers.dart';
import '../../work_schedule/providers/work_schedule_providers.dart';
import '../../work_schedule/domain/entities/employee_shift_entity.dart' as wsEntity;

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
    
    // Load notifications and attendance when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // For home screen we only need the latest 3 notifications
      ref.read(notificationListControllerProvider.notifier).loadNotifications(limit: 3);
      ref.read(attendanceControllerProvider.notifier).loadAttendance();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
  final notificationState = ref.watch(notificationListControllerProvider);
  final scheduleState = ref.watch(workScheduleControllerProvider);
    final locationStatusAsync = ref.watch(locationStatusProvider);
    final locationStatus = locationStatusAsync.asData?.value ?? const LocationStatusModel(
      isInsideWorkZone: false,
      locationName: '',
      distance: null,
      lastUpdate: null,
    );
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
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            // When refreshing from home, fetch just the top 3 notifications
            ref.read(notificationListControllerProvider.notifier).loadNotifications(limit: 3, refresh: true),
            ref.read(attendanceControllerProvider.notifier).loadAttendance(),
          ]);
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
              // const SizedBox(height: 24),

              
              // Location Status
              // GestureDetector(
              //   onTap: () => context.push(AppRoutePath.locationHistory),
              //   child: _LocationStatusCard(locationStatus: locationStatus),
              // )
              //     .animateOnPageLoad(animationsMap['cardOnPageLoad']!),
              // const SizedBox(height: 16),

              
              // Current Shift Section (use Work Schedule shifts mapped to AttendanceShift)
              // _AttendanceShiftSection(
              //   shifts: scheduleState.shifts.map((s) {
              //     // Map EmployeeShiftEntity -> AttendanceShift
              //     // id as string, shiftDate as YYYY-MM-DD, dayOfWeek computed
              //     String dayOfWeek() {
              //       switch (s.shiftDate.weekday) {
              //         case DateTime.monday:
              //           return 'Monday';
              //         case DateTime.tuesday:
              //           return 'Tuesday';
              //         case DateTime.wednesday:
              //           return 'Wednesday';
              //         case DateTime.thursday:
              //           return 'Thursday';
              //         case DateTime.friday:
              //           return 'Friday';
              //         case DateTime.saturday:
              //           return 'Saturday';
              //         case DateTime.sunday:
              //           return 'Sunday';
              //         default:
              //           return '';
              //       }
              //     }

              //     attendance.ShiftStatus mapStatus() {
              //       switch (s.status) {
              //         case wsEntity.ShiftStatus.scheduled:
              //           return attendance.ShiftStatus.SCHEDULED;
              //         case wsEntity.ShiftStatus.completed:
              //           return attendance.ShiftStatus.COMPLETED;
              //         case wsEntity.ShiftStatus.absent:
              //           return attendance.ShiftStatus.ABSENT;
              //         case wsEntity.ShiftStatus.cancelled:
              //           return attendance.ShiftStatus.ABSENT;
              //       }
              //       // Fallback
              //       return attendance.ShiftStatus.SCHEDULED;
              //     }

              //     return attendance.AttendanceShift(
              //       id: s.id.toString(),
              //       shiftDate: s.shiftDate.toIso8601String().split('T')[0],
              //       dayOfWeek: dayOfWeek(),
              //       scheduledStartTime: s.scheduledStartTime,
              //       scheduledEndTime: s.scheduledEndTime,
              //       checkInTime: s.checkInTime?.toIso8601String(),
              //       checkOutTime: s.checkOutTime?.toIso8601String(),
              //       workHours: s.workHours,
              //       overtimeHours: s.overtimeHours,
              //       lateMinutes: s.lateMinutes,
              //       earlyLeaveMinutes: s.earlyLeaveMinutes,
              //       status: mapStatus(),
              //       notes: s.notes,
              //     );
              //   }).toList(),
              // ).animateOnPageLoad(animationsMap['cardOnPageLoad']!),
              const SizedBox(height: 24),


              // Latest Notifications
              _LatestNotificationsSection(
                notifications: notificationState.notifications.take(3).toList(),
              ).animateOnPageLoad(animationsMap['cardOnPageLoad']!),
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
            color: Colors.black.withValues(alpha:0.05),
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
              color: theme.primaryColor.withValues(alpha:0.1),
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

class _AttendanceShiftSection extends StatelessWidget {
  final List<attendance.AttendanceShift> shifts;

  const _AttendanceShiftSection({required this.shifts});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final now = DateTime.now();

  attendance.AttendanceShift? displayShift;
    String label = 'No incoming shift';
    bool isCurrent = false;

    // Sort shifts by date and time to ensure correct order
  final sortedShifts = List<attendance.AttendanceShift>.from(shifts);
    sortedShifts.sort((a, b) {
      final dateA = DateTime.parse('${a.shiftDate}T${a.scheduledStartTime}');
      final dateB = DateTime.parse('${b.shiftDate}T${b.scheduledStartTime}');
      return dateA.compareTo(dateB);
    });

    for (final shift in sortedShifts) {
      // Parse dates
      // shiftDate is YYYY-MM-DD
      // scheduledStartTime is HH:mm or HH:mm:ss
      // We need to handle potential format differences, but assuming ISO-like
      try {
        final startDateTime = _parseDateTime(shift.shiftDate, shift.scheduledStartTime);
        final endDateTime = _parseDateTime(shift.shiftDate, shift.scheduledEndTime);

        if (now.isAfter(startDateTime) && now.isBefore(endDateTime)) {
          displayShift = shift;
          label = 'Current Shift';
          isCurrent = true;
          break; // Found current shift, stop searching
        } else if (now.isBefore(startDateTime)) {
          if (displayShift == null) {
            displayShift = shift;
            label = 'Incoming Shift';
            // Don't break yet, in case we find a "Current" shift later (though unlikely if sorted)
            // Actually, if we found an incoming one, and we are sorted, this is the NEXT one.
            // But we should check if there's a current one overlapping? 
            // Assuming no overlapping shifts for now.
            break; 
          }
        }
      } catch (e) {
        print('Error parsing shift date: $e');
        continue;
      }
    }

    if (displayShift == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.primaryText.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shift Schedule',
              style: theme.subtitle1.override(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No incoming shift',
              style: theme.bodyText2.override(
                color: theme.secondaryText,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.access_time, 
              color: isCurrent ? theme.info : theme.warning, 
              size: 20
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.subtitle1.override(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AttendanceShiftItem(
          shift: displayShift,
          showOvertime: false,
          showWorkHours: false,
        ),
      ],
    );
  }

  DateTime _parseDateTime(String date, String time) {
    // date: YYYY-MM-DD
    // time: HH:mm or HH:mm:ss
    // If time is just HH:mm, append :00
    String timeStr = time;
    if (time.length == 5) {
      timeStr = '$time:00';
    }
    return DateTime.parse('${date}T$timeStr');
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

    return GestureDetector(
      onTap: () => _showNotificationDialog(context, theme, icon, iconColor),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              offset: const Offset(0, 2),
              color: Colors.black.withOpacity(0.05),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    notification.title,
                    style: theme.bodyText1.override(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
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
      ),
    );
  }

  void _showNotificationDialog(
    BuildContext context,
    FlutterFlowTheme theme,
    IconData icon,
    Color iconColor,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: iconColor, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          notification.title,
                          style: theme.title3.override(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: theme.secondaryText),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(
                      maxHeight: 400,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.primaryBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        notification.message,
                        style: theme.bodyText1.override(
                          color: theme.primaryText,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: theme.secondaryText,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getTimeAgo(notification.createdAt),
                        style: theme.bodyText2.override(
                          color: theme.secondaryText,
                        ),
                      ),
                      const Spacer(),
                      if (!notification.isRead)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Unread',
                            style: theme.bodyText2.override(
                              color: theme.error,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
      // {
      //   'icon': Icons.check_circle_outline,
      //   'label': 'Check In/Out',
      //   'color': theme.primaryColor,
      //   'path': AppRoutePath.attendanceCheck,
      // },
      {
        'icon': Icons.event_note,
        'label': 'Leaves',
        'color': theme.success,
        'path': AppRoutePath.leaves,
      },
      {
        'icon': Icons.access_time,
        'label': 'Overtime',
        'color': theme.warning,
        'path': AppRoutePath.overtimes,
      },
      // {
      //   'icon': Icons.schedule_outlined,
      //   'label': 'Schedule',
      //   'color': theme.secondaryColor,
      //   'path': AppRoutePath.schedule,
      // },
    ];

    final Color accent = theme.primaryColor;

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

          return InkWell(
            onTap: () => context.push(action['path'] as String),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // <— NỀN TRẮNG TINH
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2), // Viền siêu mỏng + neutral
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04), // Shadow nhẹ nhất
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    action['icon'] as IconData,
                    color: accent, // Chỉ icon dùng primary
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action['label'] as String,
                    style: theme.bodyText2.override(
                      color: theme.primaryText, // text đen xám = chuyên nghiệp
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

