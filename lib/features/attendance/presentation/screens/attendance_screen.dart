import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/routes.dart';
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
  final List<String> _statusOptions = [
    'All',
    'SCHEDULED',
    'IN_PROGRESS',
    'COMPLETED',
    'ON_LEAVE',
    'ABSENT',
  ];

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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go(AppRoutePath.home);
        }
      },
      child: Scaffold(
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(AppRoutePath.home),
          ),
        ),
        body: Column(
          children: [
            _buildFilterSection(context, state),
            Expanded(
              child: _buildContent(state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, AttendanceState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Range Selector
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  context,
                  label: 'Start Date',
                  date: DateTime.parse(state.startDate),
                  onDateSelected: (date) {
                    final endDate = DateTime.parse(state.endDate);
                    if (date.isBefore(endDate) || date.isAtSameMomentAs(endDate)) {
                      ref
                          .read(attendanceControllerProvider.notifier)
                          .updateDateRange(date, endDate);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Start date must be before end date'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.arrow_forward, color: Colors.grey, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateButton(
                  context,
                  label: 'End Date',
                  date: DateTime.parse(state.endDate),
                  onDateSelected: (date) {
                    final startDate = DateTime.parse(state.startDate);
                    if (date.isAfter(startDate) || date.isAtSameMomentAs(startDate)) {
                      ref
                          .read(attendanceControllerProvider.notifier)
                          .updateDateRange(startDate, date);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('End date must be after start date'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Quick Date Range Buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickDateButton('This Week', () {
                  final now = DateTime.now();
                  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                  final endOfWeek = startOfWeek.add(const Duration(days: 6));
                  ref
                      .read(attendanceControllerProvider.notifier)
                      .updateDateRange(startOfWeek, endOfWeek);
                }),
                const SizedBox(width: 8),
                _buildQuickDateButton('This Month', () {
                  final now = DateTime.now();
                  final startOfMonth = DateTime(now.year, now.month, 1);
                  final endOfMonth = DateTime(now.year, now.month + 1, 0);
                  ref
                      .read(attendanceControllerProvider.notifier)
                      .updateDateRange(startOfMonth, endOfMonth);
                }),
                const SizedBox(width: 8),
                _buildQuickDateButton('Last 30 Days', () {
                  final now = DateTime.now();
                  final thirtyDaysAgo = now.subtract(const Duration(days: 30));
                  ref
                      .read(attendanceControllerProvider.notifier)
                      .updateDateRange(thirtyDaysAgo, now);
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Status Filter Dropdown
          Row(
            children: [
              Text(
                'Status:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: state.selectedStatus,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.black54, size: 20),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                      dropdownColor: Colors.white,
                      items: _statusOptions.map((String status) {
                        return DropdownMenuItem<String?>(
                          value: status == 'All' ? null : status,
                          child: Text(_getStatusLabel(status)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue == null) {
                          ref
                              .read(attendanceControllerProvider.notifier)
                              .clearStatusFilter();
                        } else {
                          ref
                              .read(attendanceControllerProvider.notifier)
                              .updateStatus(newValue);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton(
    BuildContext context, {
    required String label,
    required DateTime date,
    required Function(DateTime) onDateSelected,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.blue,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.blue[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy').format(date),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Icon(Icons.calendar_today, size: 16, color: Colors.blue[700]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDateButton(String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        side: BorderSide(color: Colors.blue.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, color: Colors.blue),
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'All':
        return 'All';
      case 'SCHEDULED':
        return 'In Coming';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'COMPLETED':
        return 'Completed';
      case 'ON_LEAVE':
        return 'On Leave';
      case 'ABSENT':
        return 'Absent';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'All':
        return Colors.grey;
      case 'SCHEDULED':
        return Colors.blue;
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'COMPLETED':
        return Colors.green;
      case 'ON_LEAVE':
        return Colors.purple;
      case 'ABSENT':
        return Colors.red;
      default:
        return Colors.grey;
    }
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
          // Summary Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryItem(
                          'Working Days',
                          '${summary.daysPresent}/${summary.totalWorkingDays}',
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey[200],
                      ),
                      Expanded(
                        child: _buildSummaryItem(
                          'Work Hours',
                          '${summary.totalWorkHours}h',
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 24, color: Colors.grey[200]),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryItem(
                          'Late / Early',
                          '${summary.timesLate} / ${summary.timesEarlyLeave}',
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey[200],
                      ),
                      Expanded(
                        child: _buildSummaryItem(
                          'Overtime',
                          '${summary.totalOvertimeHours}h',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // const Text(
                //   'Shift History',
                //   style: TextStyle(
                //     fontSize: 18,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                // if (state.selectedStatus != null)
                //   Container(
                //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                //     decoration: BoxDecoration(
                //       color: _getStatusColor(state.selectedStatus!).withOpacity(0.2),
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //     child: Text(
                //       _getStatusLabel(state.selectedStatus!),
                //       style: TextStyle(
                //         fontSize: 12,
                //         fontWeight: FontWeight.bold,
                //         color: _getStatusColor(state.selectedStatus!),
                //       ),
                //     ),
                //   ),
              ],
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


  Widget _buildSummaryItem(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}