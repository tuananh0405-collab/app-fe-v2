import '../../domain/entities/employee_shift_entity.dart';

class EmployeeShiftModel extends EmployeeShiftEntity {
  const EmployeeShiftModel({
    required super.id,
    required super.employeeId,
    required super.employeeCode,
    required super.departmentId,
    required super.shiftDate,
    required super.workScheduleId,
    required super.scheduledStartTime,
    required super.scheduledEndTime,
    super.checkInTime,
    super.checkOutTime,
    super.workHours,
    super.overtimeHours,
    super.breakHours,
    super.lateMinutes,
    super.earlyLeaveMinutes,
    required super.status,
    super.notes,
  });

  factory EmployeeShiftModel.fromJson(Map<String, dynamic> json) {
    return EmployeeShiftModel(
      id: (json['id'] as num).toInt(),
      employeeId: (json['employee_id'] as num).toInt(),
      employeeCode: json['employee_code'] as String,
      departmentId: (json['department_id'] as num).toInt(),
      shiftDate: DateTime.parse(json['shift_date'] as String),
      workScheduleId: (json['work_schedule_id'] as num).toInt(),
      scheduledStartTime: json['scheduled_start_time'] as String,
      scheduledEndTime: json['scheduled_end_time'] as String,
      checkInTime: json['check_in_time'] != null
          ? DateTime.parse(json['check_in_time'] as String)
          : null,
      checkOutTime: json['check_out_time'] != null
          ? DateTime.parse(json['check_out_time'] as String)
          : null,
      workHours: (json['work_hours'] as num?)?.toDouble() ?? 0,
      overtimeHours: (json['overtime_hours'] as num?)?.toDouble() ?? 0,
      breakHours: (json['break_hours'] as num?)?.toDouble() ?? 0,
      lateMinutes: (json['late_minutes'] as num?)?.toInt() ?? 0,
      earlyLeaveMinutes: (json['early_leave_minutes'] as num?)?.toInt() ?? 0,
      status: _parseStatus(json['status'] as String?),
      notes: json['notes'] as String?,
    );
  }

  static ShiftStatus _parseStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'SCHEDULED':
        return ShiftStatus.scheduled;
      case 'COMPLETED':
        return ShiftStatus.completed;
      case 'ABSENT':
        return ShiftStatus.absent;
      case 'CANCELLED':
        return ShiftStatus.cancelled;
      default:
        return ShiftStatus.scheduled;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'employee_code': employeeCode,
      'department_id': departmentId,
      'shift_date': shiftDate.toIso8601String().split('T')[0],
      'work_schedule_id': workScheduleId,
      'scheduled_start_time': scheduledStartTime,
      'scheduled_end_time': scheduledEndTime,
      if (checkInTime != null) 'check_in_time': checkInTime!.toIso8601String(),
      if (checkOutTime != null)
        'check_out_time': checkOutTime!.toIso8601String(),
      'work_hours': workHours,
      'overtime_hours': overtimeHours,
      'break_hours': breakHours,
      'late_minutes': lateMinutes,
      'early_leave_minutes': earlyLeaveMinutes,
      'status': status.toString().split('.').last.toUpperCase(),
      if (notes != null) 'notes': notes,
    };
  }
}

