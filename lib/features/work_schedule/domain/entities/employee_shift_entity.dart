enum ShiftStatus {
  scheduled,
  completed,
  absent,
  cancelled,
}

class EmployeeShiftEntity {
  final int id;
  final int employeeId;
  final String employeeCode;
  final int departmentId;
  final DateTime shiftDate;
  final int workScheduleId;
  final String scheduledStartTime;
  final String scheduledEndTime;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final double workHours;
  final double overtimeHours;
  final double breakHours;
  final int lateMinutes;
  final int earlyLeaveMinutes;
  final ShiftStatus status;
  final String? notes;
  final String? scheduleName;

  const EmployeeShiftEntity({
    required this.id,
    required this.employeeId,
    required this.employeeCode,
    required this.departmentId,
    required this.shiftDate,
    required this.workScheduleId,
    required this.scheduledStartTime,
    required this.scheduledEndTime,
    this.checkInTime,
    this.checkOutTime,
    this.workHours = 0,
    this.overtimeHours = 0,
    this.breakHours = 0,
    this.lateMinutes = 0,
    this.earlyLeaveMinutes = 0,
    required this.status,
    this.notes,
    this.scheduleName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployeeShiftEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

