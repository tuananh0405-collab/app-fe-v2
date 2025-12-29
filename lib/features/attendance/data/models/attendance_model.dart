import 'package:equatable/equatable.dart';
import '../../domain/entities/attendance_entity.dart';


class AttendanceShiftModel extends Equatable {
  final String id;
  final String shiftDate;
  final String dayOfWeek;
  final String scheduledStartTime;
  final String scheduledEndTime;
  final String? checkInTime;
  final String? checkOutTime;
  final double workHours;
  final double overtimeHours;
  final int lateMinutes;
  final int earlyLeaveMinutes;
  final ShiftStatus status;
  final String? notes;

  const AttendanceShiftModel({
    required this.id,
    required this.shiftDate,
    required this.dayOfWeek,
    required this.scheduledStartTime,
    required this.scheduledEndTime,
    this.checkInTime,
    this.checkOutTime,
    required this.workHours,
    required this.overtimeHours,
    required this.lateMinutes,
    required this.earlyLeaveMinutes,
    required this.status,
    this.notes,
  });

  factory AttendanceShiftModel.fromJson(Map<String, dynamic> json) {
    return AttendanceShiftModel(
      id: json['id'].toString(),
      shiftDate: json['shift_date'],
      dayOfWeek: json['day_of_week'],
      scheduledStartTime: json['scheduled_start_time'],
      scheduledEndTime: json['scheduled_end_time'],
      checkInTime: json['check_in_time'],
      checkOutTime: json['check_out_time'],
      workHours: _parseDouble(json['work_hours']),
      overtimeHours: _parseDouble(json['overtime_hours']),
      lateMinutes: _parseInt(json['late_minutes']),
      earlyLeaveMinutes: _parseInt(json['early_leave_minutes']),
      status: _parseStatus(json['status']),
      notes: json['notes'],
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static ShiftStatus _parseStatus(String status) {
    switch (status) {
      case 'SCHEDULED':
        return ShiftStatus.SCHEDULED;
      case 'IN_PROGRESS':
        return ShiftStatus.IN_PROGRESS;
      case 'COMPLETED':
        return ShiftStatus.COMPLETED;
      case 'ABSENT':
        return ShiftStatus.ABSENT;
      case 'ON_LEAVE':
        return ShiftStatus.ON_LEAVE;
      default:
        return ShiftStatus.SCHEDULED;
    }
  }

  AttendanceShift toEntity() {
    return AttendanceShift(
      id: id,
      shiftDate: shiftDate,
      dayOfWeek: dayOfWeek,
      scheduledStartTime: scheduledStartTime,
      scheduledEndTime: scheduledEndTime,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      workHours: workHours,
      overtimeHours: overtimeHours,
      lateMinutes: lateMinutes,
      earlyLeaveMinutes: earlyLeaveMinutes,
      status: status,
      notes: notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        shiftDate,
        dayOfWeek,
        scheduledStartTime,
        scheduledEndTime,
        checkInTime,
        checkOutTime,
        workHours,
        overtimeHours,
        lateMinutes,
        earlyLeaveMinutes,
        status,
        notes,
      ];
}

class AttendanceSummaryModel extends Equatable {
  final int totalWorkingDays;
  final int daysPresent;
  final int daysAbsent;
  final int daysOnLeave;
  final double totalWorkHours;
  final double totalOvertimeHours;
  final int timesLate;
  final int totalLateMinutes;
  final int timesEarlyLeave;
  final int totalEarlyLeaveMinutes;

  const AttendanceSummaryModel({
    required this.totalWorkingDays,
    required this.daysPresent,
    required this.daysAbsent,
    required this.daysOnLeave,
    required this.totalWorkHours,
    required this.totalOvertimeHours,
    required this.timesLate,
    required this.totalLateMinutes,
    required this.timesEarlyLeave,
    required this.totalEarlyLeaveMinutes,
  });

  factory AttendanceSummaryModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSummaryModel(
      totalWorkingDays: json['total_working_days'],
      daysPresent: json['days_present'],
      daysAbsent: json['days_absent'],
      daysOnLeave: json['days_on_leave'],
      totalWorkHours: (json['total_work_hours'] as num?)?.toDouble() ?? 0.0,
      totalOvertimeHours: (json['total_overtime_hours'] as num?)?.toDouble() ?? 0.0,
      timesLate: json['times_late'],
      totalLateMinutes: json['total_late_minutes'],
      timesEarlyLeave: json['times_early_leave'],
      totalEarlyLeaveMinutes: json['total_early_leave_minutes'],
    );
  }

  AttendanceSummary toEntity() {
    return AttendanceSummary(
      totalWorkingDays: totalWorkingDays,
      daysPresent: daysPresent,
      daysAbsent: daysAbsent,
      daysOnLeave: daysOnLeave,
      totalWorkHours: totalWorkHours,
      totalOvertimeHours: totalOvertimeHours,
      timesLate: timesLate,
      totalLateMinutes: totalLateMinutes,
      timesEarlyLeave: timesEarlyLeave,
      totalEarlyLeaveMinutes: totalEarlyLeaveMinutes,
    );
  }

  @override
  List<Object?> get props => [
        totalWorkingDays,
        daysPresent,
        daysAbsent,
        daysOnLeave,
        totalWorkHours,
        totalOvertimeHours,
        timesLate,
        totalLateMinutes,
        timesEarlyLeave,
        totalEarlyLeaveMinutes,
      ];
}

class AttendanceResponseModel extends Equatable {
  final AttendanceSummaryModel summary;
  final List<AttendanceShiftModel> shifts;
  final String periodStart;
  final String periodEnd;

  const AttendanceResponseModel({
    required this.summary,
    required this.shifts,
    required this.periodStart,
    required this.periodEnd,
  });

  factory AttendanceResponseModel.fromJson(Map<String, dynamic> json) {
    return AttendanceResponseModel(
      summary: AttendanceSummaryModel.fromJson(json['summary']),
      shifts: (json['shifts'] as List)
          .map((e) => AttendanceShiftModel.fromJson(e))
          .toList(),
      periodStart: json['period_start'],
      periodEnd: json['period_end'],
    );
  }

  AttendanceResponse toEntity() {
    return AttendanceResponse(
      summary: summary.toEntity(),
      shifts: shifts.map((e) => e.toEntity()).toList(),
      periodStart: periodStart,
      periodEnd: periodEnd,
    );
  }

  @override
  List<Object?> get props => [summary, shifts, periodStart, periodEnd];
}
