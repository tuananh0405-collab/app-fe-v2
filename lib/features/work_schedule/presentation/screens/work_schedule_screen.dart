import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../flutter_flow/flutter_flow.dart';
import '../../domain/entities/employee_shift_entity.dart';
import '../../providers/work_schedule_providers.dart';

class WorkScheduleScreen extends ConsumerStatefulWidget {
  const WorkScheduleScreen({super.key});

  @override
  ConsumerState<WorkScheduleScreen> createState() =>
      _WorkScheduleScreenState();
}

class _WorkScheduleScreenState extends ConsumerState<WorkScheduleScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late DateTime _rangeStart;
  late DateTime _rangeEnd;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = now;
    _selectedDay = now;
    _rangeStart = DateTime(now.year, now.month, 1);
    _rangeEnd = DateTime(now.year, now.month + 2, 0);

    // Load shifts for the next 3 months
    Future.microtask(() {
      ref.read(workScheduleControllerProvider.notifier).loadShifts(
            fromDate: _rangeStart,
            toDate: _rangeEnd,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final scheduleState = ref.watch(workScheduleControllerProvider);
    final controller = ref.read(workScheduleControllerProvider.notifier);

    // Listen for error messages
    ref.listen(workScheduleControllerProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        showSnackbar(context, next.errorMessage!);
      }
    });

    // Get shifts for selected day
    final selectedDayShifts = controller.getShiftsForDate(_selectedDay);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        title: Text(
          'Work Schedule',
          style: theme.title2.override(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 2,
        backgroundColor: theme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          FFIconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () {
              controller.loadShifts(
                fromDate: _rangeStart,
                toDate: _rangeEnd,
              );
            },
            buttonSize: 48,
          ),
        ],
      ),
      body: scheduleState.isLoading
          ? Center(child: FFLoadingIndicator(color: theme.primaryColor))
          : RefreshIndicator(
              onRefresh: () async {
                await controller.loadShifts(
                  fromDate: _rangeStart,
                  toDate: _rangeEnd,
                );
              },
              color: theme.primaryColor,
              child: Column(
                children: [
                  // Calendar Section
                  _buildCalendarSection(theme, scheduleState, controller),
                  
                  // Divider
                  Divider(height: 1, color: theme.secondaryText.withValues(alpha: 0.2)),
                  
                  // Timeline and Shift Details Section
                  // Expanded(
                  //   child: Row(
                  //     children: [
                  //       // Timeline (Left)
                  //       Expanded(
                  //         flex: 1,
                  //         child: _buildTimelineSection(
                  //           theme,
                  //           scheduleState,
                  //           controller,
                  //         ),
                  //       ),
                        
                  //       // Divider
                  //       VerticalDivider(
                  //         width: 1,
                  //         color: theme.secondaryText.withValues(alpha: 0.2),
                  //       ),
                        
                        // Shift Details (Right)
                        Expanded(
                          flex: 2,
                          child: _buildShiftDetailsSection(
                            theme,
                            selectedDayShifts,
                            _selectedDay,
                          ),
                        ),
                    //   ],
                    // ),
                  // ),
                ],
              ),
            ),
    );
  }

  Widget _buildCalendarSection(
    FlutterFlowTheme theme,
    dynamic scheduleState,
    dynamic controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar<EmployeeShiftEntity>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        rangeStartDay: null,
        rangeEndDay: null,
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: theme.subtitle1.override(
            fontWeight: FontWeight.bold,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: theme.primaryColor,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: theme.primaryColor,
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          selectedDecoration: BoxDecoration(
            color: theme.primaryColor,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: theme.success,
            shape: BoxShape.circle,
          ),
        ),
        eventLoader: (day) {
          final shifts = controller.getShiftsForDate(day);
          // Limit to maximum 4 dots per day
          return shifts.take(4).toList();
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          controller.selectDate(selectedDay);
        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
          controller.setFocusedDate(focusedDay);
          
          // Update range and load more data if needed
          final newRangeStart = DateTime(focusedDay.year, focusedDay.month, 1);
          final newRangeEnd = DateTime(focusedDay.year, focusedDay.month + 2, 0);
          
          if (newRangeStart.isBefore(_rangeStart) ||
              newRangeEnd.isAfter(_rangeEnd)) {
            _rangeStart = newRangeStart;
            _rangeEnd = newRangeEnd;
            controller.loadShifts(
              fromDate: _rangeStart,
              toDate: _rangeEnd,
            );
          }
        },
      ),
    );
  }

  Widget _buildTimelineSection(
    FlutterFlowTheme theme,
    dynamic scheduleState,
    dynamic controller,
  ) {
    // Get all shifts sorted by date and time
    final allShifts = List<EmployeeShiftEntity>.from(scheduleState.shifts)
      ..sort((a, b) {
        final dateCompare = a.shiftDate.compareTo(b.shiftDate);
        if (dateCompare != 0) return dateCompare;
        return a.scheduledStartTime.compareTo(b.scheduledStartTime);
      });

    if (allShifts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No shifts scheduled',
            style: theme.bodyText1.override(
              color: theme.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: allShifts.length,
      itemBuilder: (context, index) {
        final shift = allShifts[index];
        final dateFormat = DateFormat('MMM dd');
        final isSelected = _selectedDay.year == shift.shiftDate.year &&
            _selectedDay.month == shift.shiftDate.month &&
            _selectedDay.day == shift.shiftDate.day;

        // Parse time strings
        final startTimeParts = shift.scheduledStartTime.split(':');
        final endTimeParts = shift.scheduledEndTime.split(':');
        
        return InkWell(
          onTap: () {
            setState(() {
              _selectedDay = shift.shiftDate;
              _focusedDay = shift.shiftDate;
            });
            controller.selectDate(shift.shiftDate);
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected 
                  ? theme.primaryColor.withValues(alpha: 0.08)
                  : theme.secondaryBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? theme.primaryColor.withValues(alpha: 0.3)
                    : theme.secondaryText.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dateFormat.format(shift.shiftDate),
                  style: theme.bodyText2.override(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? theme.primaryColor : theme.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: theme.secondaryText,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${startTimeParts[0]}:${startTimeParts[1]} - ${endTimeParts[0]}:${endTimeParts[1]}',
                        style: theme.bodyText2.override(
                          fontSize: 11,
                          color: theme.secondaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShiftDetailsSection(
    FlutterFlowTheme theme,
    List<EmployeeShiftEntity> shifts,
    DateTime selectedDate,
  ) {
    final dateFormat = DateFormat('EEEE, MMM dd, yyyy');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dateFormat.format(selectedDate),
            style: theme.title3.override(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          if (shifts.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 64,
                      color: theme.secondaryText.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No shifts scheduled',
                      style: theme.bodyText1.override(
                        color: theme.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 4),
                itemCount: shifts.length,
                itemBuilder: (context, index) {
                  final shift = shifts[index];
                  return _buildShiftDetailCard(theme, shift);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShiftDetailCard(
    FlutterFlowTheme theme,
    EmployeeShiftEntity shift,
  ) {
    final timeFormat = DateFormat('HH:mm');
    final startTimeParts = shift.scheduledStartTime.split(':');
    final endTimeParts = shift.scheduledEndTime.split(':');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.secondaryText.withValues(alpha: 0.1),
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
          // Header with Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  shift.scheduleName ?? 'Shift #${shift.id}',
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
                  color: _getStatusColor(shift.status, theme)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusText(shift.status),
                  style: theme.bodyText2.override(
                    fontSize: 11,
                    color: _getStatusColor(shift.status, theme),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Scheduled Time
          _buildDetailRow(
            theme,
            Icons.access_time,
            'Scheduled',
            '${startTimeParts[0]}:${startTimeParts[1]} - ${endTimeParts[0]}:${endTimeParts[1]}',
          ),
          const SizedBox(height: 8),
          
          // Check In/Out Times
          if (shift.checkInTime != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildDetailRow(
                theme,
                Icons.login,
                'Check In',
                timeFormat.format(shift.checkInTime!),
              ),
            ),
          if (shift.checkOutTime != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildDetailRow(
                theme,
                Icons.logout,
                'Check Out',
                timeFormat.format(shift.checkOutTime!),
              ),
            ),
          
          // Work Hours
          // _buildDetailRow(
          //   theme,
          //   Icons.work_outline,
          //   'Work Hours',
          //   '${shift.workHours.toStringAsFixed(1)}h',
          // ),
          
          if (shift.overtimeHours > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _buildDetailRow(
                theme,
                Icons.timer_outlined,
                'Overtime',
                '${shift.overtimeHours.toStringAsFixed(1)}h',
              ),
            ),
          if (shift.breakHours > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _buildDetailRow(
                theme,
                Icons.coffee_outlined,
                'Break',
                '${shift.breakHours.toStringAsFixed(1)}h',
              ),
            ),
          if (shift.lateMinutes > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _buildDetailRow(
                theme,
                Icons.warning_amber_rounded,
                'Late',
                '${shift.lateMinutes}min',
                color: theme.error,
              ),
            ),
          if (shift.earlyLeaveMinutes > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _buildDetailRow(
                theme,
                Icons.warning_amber_rounded,
                'Early Leave',
                '${shift.earlyLeaveMinutes}min',
                color: theme.error,
              ),
            ),
          if (shift.notes != null && shift.notes!.isNotEmpty)
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
                        shift.notes!,
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

  Widget _buildDetailRow(
    FlutterFlowTheme theme,
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: color ?? theme.secondaryText,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            '$label: ',
            style: theme.bodyText2.override(
              fontSize: 12,
              color: theme.secondaryText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          value,
          style: theme.bodyText2.override(
            fontSize: 12,
            color: color ?? theme.primaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(ShiftStatus status, FlutterFlowTheme theme) {
    switch (status) {
      case ShiftStatus.scheduled:
        return theme.warning;
      case ShiftStatus.inProgress:
        return theme.primaryColor;
      case ShiftStatus.completed:
        return theme.success;
      case ShiftStatus.absent:
        return theme.error;
      case ShiftStatus.cancelled:
        return theme.secondaryText;
    }
  }

  String _getStatusText(ShiftStatus status) {
    switch (status) {
      case ShiftStatus.scheduled:
        return 'In Coming';
      case ShiftStatus.inProgress:
        return 'In Progress';
      case ShiftStatus.completed:
        return 'Completed';
      case ShiftStatus.absent:
        return 'Absent';
      case ShiftStatus.cancelled:
        return 'Cancelled';
    }
  }
}