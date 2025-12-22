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
import 'package:intl/intl.dart';

import '../../attendance/domain/entities/attendance_entity.dart' as attendance;
import '../../attendance/presentation/widgets/attendance_shift_item.dart';
import '../../attendance/providers/attendance_providers.dart';
import '../../work_schedule/providers/work_schedule_providers.dart';
import '../../work_schedule/domain/entities/employee_shift_entity.dart' as wsEntity;
import '../../overtime/providers/overtime_providers.dart';

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
    
    // Load notifications and work schedule when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // For home screen we only need the latest 3 notifications
      ref.read(notificationListControllerProvider.notifier).loadNotifications(limit: 3);
      
      final now = DateTime.now();
      // Load shifts for today only
      final start = DateTime(now.year, now.month, now.day);
      final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
      ref.read(workScheduleControllerProvider.notifier).loadShifts(fromDate: start, toDate: end);
      
      // Load overtime requests for today
      ref.read(overtimeControllerProvider.notifier).getMyOvertimeRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final notificationState = ref.watch(notificationListControllerProvider);
    final scheduleState = ref.watch(workScheduleControllerProvider);
    final overtimeState = ref.watch(overtimeControllerProvider);
    
    // Filter for today's shifts only (in case state has a larger range loaded)
    final now = DateTime.now();
    final todayShifts = scheduleState.shifts.where((s) {
      return s.shiftDate.year == now.year && 
             s.shiftDate.month == now.month && 
             s.shiftDate.day == now.day;
    });
    


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
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              context.push(AppRoutePath.notifications);
            },
          ),
        ],
      ),
      body: Container(
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
              const SizedBox(height: 16),

              
              // Current Shift Section (use Work Schedule shifts mapped to AttendanceShift)
              _AttendanceShiftSection(
                shifts: todayShifts.map((s) {
                  // Map EmployeeShiftEntity -> AttendanceShift
                  // id as string, shiftDate as YYYY-MM-DD, dayOfWeek computed
                  String dayOfWeek() {
                    switch (s.shiftDate.weekday) {
                      case DateTime.monday:
                        return 'Monday';
                      case DateTime.tuesday:
                        return 'Tuesday';
                      case DateTime.wednesday:
                        return 'Wednesday';
                      case DateTime.thursday:
                        return 'Thursday';
                      case DateTime.friday:
                        return 'Friday';
                      case DateTime.saturday:
                        return 'Saturday';
                      case DateTime.sunday:
                        return 'Sunday';
                      default:
                        return '';
                    }
                  }

                  attendance.ShiftStatus mapStatus() {
                    switch (s.status) {
                      case wsEntity.ShiftStatus.scheduled:
                        return attendance.ShiftStatus.SCHEDULED;
                      case wsEntity.ShiftStatus.inProgress:
                        return attendance.ShiftStatus.IN_PROGRESS;
                      case wsEntity.ShiftStatus.completed:
                        return attendance.ShiftStatus.COMPLETED;
                      case wsEntity.ShiftStatus.absent:
                        return attendance.ShiftStatus.ABSENT;
                      case wsEntity.ShiftStatus.cancelled:
                        return attendance.ShiftStatus.ABSENT;
                    }
                    // Fallback
                    return attendance.ShiftStatus.SCHEDULED;
                  }

                  return attendance.AttendanceShift(
                    id: s.id.toString(),
                    shiftDate: s.shiftDate.toIso8601String().split('T')[0],
                    dayOfWeek: dayOfWeek(),
                    scheduledStartTime: s.scheduledStartTime,
                    scheduledEndTime: s.scheduledEndTime,
                    checkInTime: s.checkInTime?.toIso8601String(),
                    checkOutTime: s.checkOutTime?.toIso8601String(),
                    workHours: s.workHours,
                    overtimeHours: s.overtimeHours,
                    lateMinutes: s.lateMinutes,
                    earlyLeaveMinutes: s.earlyLeaveMinutes,
                    status: mapStatus(),
                    notes: s.notes,
                  );
                }).toList(),
              ).animateOnPageLoad(animationsMap['cardOnPageLoad']!),
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

class _AttendanceShiftSection extends ConsumerWidget {
  final List<attendance.AttendanceShift> shifts;

  const _AttendanceShiftSection({required this.shifts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = FlutterFlowTheme.of(context);
    final now = DateTime.now();
    final controller = ref.read(workScheduleControllerProvider.notifier);
    
    // Check for holiday/leave on today
    final holidayInfo = controller.getHolidayInfoForDate(now);
    final leaveInfo = controller.getLeaveInfoForDate(now);
    final overtimes = controller.getOvertimesForDate(now);

    // If there's a holiday or leave, don't show regular shifts
    final shouldShowShifts = holidayInfo == null && leaveInfo == null;

    // Check for current or incoming overtime
    dynamic currentOvertime;
    dynamic incomingOvertime;
    String overtimeLabel = '';
    bool isOvertimeCurrent = false;
    
    if (overtimes.isNotEmpty) {
      for (final overtime in overtimes) {
        try {
          final startTime = overtime.startTime as DateTime;
          final endTime = overtime.endTime as DateTime;
          
          // Check if overtime is currently active
          if (now.isAfter(startTime) && now.isBefore(endTime)) {
            currentOvertime = overtime;
            overtimeLabel = 'Current Overtime';
            isOvertimeCurrent = true;
            break;
          }
          
          // Check if overtime is starting within 15 minutes
          final timeUntilStart = startTime.difference(now).inMinutes;
          if (timeUntilStart > 0 && timeUntilStart <= 15) {
            if (incomingOvertime == null) {
              incomingOvertime = overtime;
              overtimeLabel = 'Incoming Overtime';
            }
          }
        } catch (e) {
          print('Error parsing overtime: $e');
          continue;
        }
      }
    }

    attendance.AttendanceShift? displayShift;
    String label = 'No incoming shift today';
    bool isCurrent = false;

    // Only process shifts if we should show them and no current/incoming overtime
    if (shouldShowShifts && shifts.isNotEmpty && currentOvertime == null && incomingOvertime == null) {
      // Sort shifts by date and time to ensure correct order
      final sortedShifts = List<attendance.AttendanceShift>.from(shifts);
      sortedShifts.sort((a, b) {
        final dateA = _parseDateTime(a.shiftDate, a.scheduledStartTime);
        final dateB = _parseDateTime(b.shiftDate, b.scheduledStartTime);
        return dateA.compareTo(dateB);
      });

      for (final shift in sortedShifts) {
        try {
          final startDateTime = _parseDateTime(shift.shiftDate, shift.scheduledStartTime);
          final endDateTime = _parseDateTime(shift.shiftDate, shift.scheduledEndTime);

          if (now.isAfter(startDateTime) && now.isBefore(endDateTime)) {
            displayShift = shift;
            label = 'Current Shift';
            isCurrent = true;
            break;
          } else if (now.isBefore(startDateTime)) {
            if (displayShift == null) {
              displayShift = shift;
              label = 'Incoming Shift';
              break; 
            }
          }
        } catch (e) {
          print('Error parsing shift date: $e');
          continue;
        }
      }
    }

    // Build the UI
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show holiday card if exists
        if (holidayInfo != null) ...[
          _buildHolidayCard(theme, holidayInfo),
          const SizedBox(height: 12),
        ],
        
        // Show leave card if exists
        if (leaveInfo != null) ...[
          _buildLeaveCard(theme, leaveInfo),
          const SizedBox(height: 12),
        ],
        
        // Show current/incoming overtime with priority
        if (currentOvertime != null || incomingOvertime != null) ...[
          Row(
            children: [
              Icon(
                Icons.timer_outlined, 
                color: isOvertimeCurrent ? const Color(0xFF7C2D12) : theme.warning, 
                size: 20
              ),
              const SizedBox(width: 8),
              Text(
                overtimeLabel,
                style: theme.subtitle1.override(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildOvertimeCard(theme, currentOvertime ?? incomingOvertime),
        ]
        // Show shift only if no holiday/leave and no current/incoming overtime
        else if (shouldShowShifts) ...[
          if (displayShift != null) ...[
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
          ] else ...[
            Container(
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
                    'No incoming shift today',
                    style: theme.bodyText2.override(
                      color: theme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
        
        // Show other overtime cards if exist (excluding the one already displayed)
        if (overtimes.isNotEmpty && overtimes.length > 1) ...[
          const SizedBox(height: 12),
          ...overtimes.where((ot) => ot != currentOvertime && ot != incomingOvertime).map((overtime) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildOvertimeCard(theme, overtime),
            );
          }).toList(),
        ],
        
        // Show info message if holiday/leave exists and there are shifts
        if (!shouldShowShifts && shifts.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.secondaryText.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.secondaryText,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Shifts are not displayed due to ${holidayInfo != null ? "holiday" : "leave"}',
                    style: theme.bodyText2.override(
                      fontSize: 12,
                      color: theme.secondaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildHolidayCard(FlutterFlowTheme theme, Map<String, dynamic> holidayInfo) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB), // gray-200
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF9CA3AF), // gray-400
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF9CA3AF).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.celebration,
              size: 24,
              color: Color(0xFF1F2937), // gray-800
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  holidayInfo['label'] as String,
                  style: theme.subtitle2.override(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937), // gray-800
                  ),
                ),
                if (holidayInfo['holiday']?.description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      holidayInfo['holiday'].description,
                      style: theme.bodyText2.override(
                        fontSize: 12,
                        color: const Color(0xFF1F2937).withValues(alpha: 0.7),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveCard(FlutterFlowTheme theme, Map<String, dynamic> leaveInfo) {
    Color color;
    Color bgColor;
    
    try {
      final colorHex = leaveInfo['color'] as String?;
      if (colorHex != null && colorHex.isNotEmpty) {
        color = Color(int.parse('0xFF${colorHex.substring(1)}'));
        bgColor = Color(int.parse('0x33${colorHex.substring(1)}')); // 20% opacity
      } else {
        // Fallback colors: purple for leave
        color = Colors.purple;
        bgColor = Colors.purple.withValues(alpha: 0.2);
      }
    } catch (e) {
      // Fallback colors if parsing fails: purple for leave
      color = Colors.purple;
      bgColor = Colors.purple.withValues(alpha: 0.2);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.event_busy,
              size: 24,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leaveInfo['label'] as String,
                  style: theme.subtitle2.override(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                if (leaveInfo['leave']?.reason != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      leaveInfo['leave'].reason,
                      style: theme.bodyText2.override(
                        fontSize: 12,
                        color: color.withValues(alpha: 0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOvertimeCard(FlutterFlowTheme theme, dynamic overtime) {
    final timeFormat = DateFormat('HH:mm');
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFDBA74).withValues(alpha: 0.3), // orange-300 with transparency
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with OT Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Overtime',
                  style: theme.subtitle2.override(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDBA74).withValues(alpha: 0.2), // orange-300
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 12,
                      color: Color(0xFF7C2D12), // orange-900
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'OT',
                      style: theme.bodyText2.override(
                        fontSize: 11,
                        color: const Color(0xFF7C2D12), // orange-900
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Time
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: theme.secondaryText,
              ),
              const SizedBox(width: 8),
              Text(
                '${timeFormat.format(overtime.startTime)} - ${timeFormat.format(overtime.endTime)}',
                style: theme.bodyText2.override(
                  fontSize: 12,
                  color: theme.secondaryText,
                ),
              ),
            ],
          ),
          
          // Reason
          if (overtime.reason != null && overtime.reason.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.primaryBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.note_outlined,
                      size: 14,
                      color: theme.secondaryText,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        overtime.reason,
                        style: theme.bodyText2.override(
                          fontSize: 12,
                          color: theme.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  DateTime _parseDateTime(String date, String time) {
    final parts = time.split(':');
    if (parts.isEmpty) return DateTime.parse('${date}T00:00:00');
    
    final hour = parts[0].padLeft(2, '0');
    final minute = parts.length > 1 ? parts[1].padLeft(2, '0') : '00';
    final second = parts.length > 2 ? parts[2].padLeft(2, '0') : '00';
    
    final formattedTime = '$hour:$minute:$second';
    return DateTime.parse('${date}T$formattedTime');
  }
}

class _TodayOvertimeSection extends StatelessWidget {
  final List<dynamic> overtimes;

  const _TodayOvertimeSection({required this.overtimes});

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.timer_outlined,
              color: const Color(0xFF7C2D12), // orange-900
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Today\'s Overtime',
              style: theme.subtitle1.override(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...overtimes.map((overtime) {
          final timeFormat = DateFormat('HH:mm');
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEDD5), // orange-100
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFDBA74), // orange-300
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDBA74).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.timer_outlined,
                    size: 20,
                    color: Color(0xFF7C2D12), // orange-900
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${timeFormat.format(overtime.startTime)} - ${timeFormat.format(overtime.endTime)}',
                        style: theme.bodyText1.override(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF7C2D12),
                        ),
                      ),
                      if (overtime.reason != null && overtime.reason.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          overtime.reason,
                          style: theme.bodyText2.override(
                            fontSize: 12,
                            color: const Color(0xFF7C2D12).withValues(alpha: 0.8),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
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

