import '../../domain/entities/work_schedule_assignment_entity.dart';

class WorkScheduleAssignmentModel extends WorkScheduleAssignmentEntity {
  const WorkScheduleAssignmentModel({
    required super.id,
    required super.employeeId,
    required super.workScheduleId,
    required super.effectiveFrom,
    required super.effectiveTo,
    required super.workSchedule,
    required super.scheduleOverrides,
  });

  factory WorkScheduleAssignmentModel.fromJson(Map<String, dynamic> json) {
    return WorkScheduleAssignmentModel(
      id: json['id'] as int,
      employeeId: json['employee_id'].toString(),
      workScheduleId: json['work_schedule_id'] as int,
      effectiveFrom: DateTime.parse(json['effective_from'] as String),
      effectiveTo: DateTime.parse(json['effective_to'] as String),
      workSchedule: WorkScheduleModel.fromJson(
        json['work_schedule'] as Map<String, dynamic>,
      ),
      scheduleOverrides: (json['schedule_overrides'] as List<dynamic>?)
              ?.map((e) => ScheduleOverrideModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'work_schedule_id': workScheduleId,
      'effective_from': effectiveFrom.toIso8601String(),
      'effective_to': effectiveTo.toIso8601String(),
      'work_schedule': (workSchedule as WorkScheduleModel).toJson(),
      'schedule_overrides': scheduleOverrides
          .map((e) => (e as ScheduleOverrideModel).toJson())
          .toList(),
    };
  }
}

class WorkScheduleModel extends WorkScheduleEntity {
  const WorkScheduleModel({
    required super.id,
    required super.scheduleName,
    required super.scheduleType,
    required super.startTime,
    required super.endTime,
    required super.breakDurationMinutes,
    required super.lateToleranceMinutes,
    required super.earlyLeaveToleranceMinutes,
    required super.status,
  });

  factory WorkScheduleModel.fromJson(Map<String, dynamic> json) {
    return WorkScheduleModel(
      id: json['id'] as int,
      scheduleName: json['schedule_name'] as String,
      scheduleType: json['schedule_type'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      breakDurationMinutes: json['break_duration_minutes'] as int,
      lateToleranceMinutes: json['late_tolerance_minutes'] as int,
      earlyLeaveToleranceMinutes: json['early_leave_tolerance_minutes'] as int,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schedule_name': scheduleName,
      'schedule_type': scheduleType,
      'start_time': startTime,
      'end_time': endTime,
      'break_duration_minutes': breakDurationMinutes,
      'late_tolerance_minutes': lateToleranceMinutes,
      'early_leave_tolerance_minutes': earlyLeaveToleranceMinutes,
      'status': status,
    };
  }
}

class ScheduleOverrideModel extends ScheduleOverrideEntity {
  const ScheduleOverrideModel({
    required super.id,
    required super.type,
    required super.reason,
    required super.status,
    required super.toDate,
    required super.fromDate,
    required super.createdAt,
    required super.createdBy,
    required super.shiftCreated,
    required super.overrideWorkScheduleId,
  });

  factory ScheduleOverrideModel.fromJson(Map<String, dynamic> json) {
    return ScheduleOverrideModel(
      id: json['id'] as String,
      type: json['type'] as String,
      reason: json['reason'] as String,
      status: json['status'] as String,
      toDate: DateTime.parse(json['to_date'] as String),
      fromDate: DateTime.parse(json['from_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      createdBy: json['created_by'] as int,
      shiftCreated: json['shift_created'] as bool,
      overrideWorkScheduleId: json['override_work_schedule_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'reason': reason,
      'status': status,
      'to_date': toDate.toIso8601String().split('T')[0],
      'from_date': fromDate.toIso8601String().split('T')[0],
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
      'shift_created': shiftCreated,
      'override_work_schedule_id': overrideWorkScheduleId,
    };
  }
}
