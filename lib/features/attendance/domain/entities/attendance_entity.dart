enum ShiftStatus {
  SCHEDULED,
  IN_PROGRESS,
  COMPLETED,
  ABSENT,
  ON_LEAVE,
}

class AttendanceShift {
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

  const AttendanceShift({
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
}

class AttendanceSummary {
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

  const AttendanceSummary({
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
}

class AttendanceResponse {
  final AttendanceSummary summary;
  final List<AttendanceShift> shifts;
  final String periodStart;
  final String periodEnd;

  const AttendanceResponse({
    required this.summary,
    required this.shifts,
    required this.periodStart,
    required this.periodEnd,
  });
}
