import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/attendance_providers.dart';
import '../state/attendance_state.dart';
import '../widgets/attendance_shift_item.dart';
import '../widgets/attendance_summary_card.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(attendanceControllerProvider.notifier).loadAttendance();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(attendanceControllerProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My Attendance',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          _buildFilterSection(context, state),
          Expanded(
            child: _buildContent(state),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, AttendanceState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Period Selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['DAY', 'WEEK', 'MONTH', 'YEAR'].map((period) {
                final isSelected = state.selectedPeriod == period;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(period),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        ref
                            .read(attendanceControllerProvider.notifier)
                            .updatePeriod(period);
                      }
                    },
                    selectedColor: Colors.blue,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Date Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  final currentDate = DateTime.parse(state.referenceDate);
                  final newDate = _adjustDate(currentDate, state.selectedPeriod, -1);
                  ref.read(attendanceControllerProvider.notifier).updateDate(newDate);
                },
              ),
              Text(
                _formatDateRange(state),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  final currentDate = DateTime.parse(state.referenceDate);
                  final newDate = _adjustDate(currentDate, state.selectedPeriod, 1);
                  ref.read(attendanceControllerProvider.notifier).updateDate(newDate);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AttendanceState state) {
    if (state.status == AttendanceStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state.status == AttendanceStatus.failure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.errorMessage ?? 'An error occurred'),
            TextButton(
              onPressed: () {
                ref.read(attendanceControllerProvider.notifier).loadAttendance();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else if (state.data == null) {
      return const Center(child: Text('No data available'));
    }

    final summary = state.data!.summary;
    final shifts = state.data!.shifts;

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(attendanceControllerProvider.notifier).loadAttendance();
      },
      child: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 32),
        children: [
          // Summary Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                AttendanceSummaryCard(
                  title: 'Working Days',
                  value: '${summary.daysPresent}/${summary.totalWorkingDays}',
                  icon: Icons.calendar_today,
                  color: Colors.blue,
                ),
                AttendanceSummaryCard(
                  title: 'Work Hours',
                  value: '${summary.totalWorkHours}h',
                  icon: Icons.access_time,
                  color: Colors.green,
                ),
                AttendanceSummaryCard(
                  title: 'Late / Early',
                  value: '${summary.timesLate} / ${summary.timesEarlyLeave}',
                  icon: Icons.warning_amber_rounded,
                  color: Colors.orange,
                ),
                AttendanceSummaryCard(
                  title: 'Overtime',
                  value: '${summary.totalOvertimeHours}h',
                  icon: Icons.timer,
                  color: Colors.purple,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Shift History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (shifts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: Text('No shifts found for this period')),
            )
          else
            ...shifts.map((shift) => AttendanceShiftItem(shift: shift)),
        ],
      ),
    );
  }

  DateTime _adjustDate(DateTime date, String period, int offset) {
    switch (period) {
      case 'DAY':
        return date.add(Duration(days: offset));
      case 'WEEK':
        return date.add(Duration(days: offset * 7));
      case 'MONTH':
        return DateTime(date.year, date.month + offset, 1);
      case 'YEAR':
        return DateTime(date.year + offset, 1, 1);
      default:
        return date;
    }
  }

  String _formatDateRange(AttendanceState state) {
    if (state.data == null) return state.referenceDate;
    return '${state.data!.periodStart} - ${state.data!.periodEnd}';
  }
}
