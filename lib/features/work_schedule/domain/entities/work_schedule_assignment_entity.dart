import 'package:equatable/equatable.dart';

class WorkScheduleAssignmentEntity extends Equatable {
  final int id;
  final String employeeId;
  final int workScheduleId;
  final DateTime effectiveFrom;
  final DateTime effectiveTo;
  final WorkScheduleEntity workSchedule;
  final List<ScheduleOverrideEntity> scheduleOverrides;

  const WorkScheduleAssignmentEntity({
    required this.id,
    required this.employeeId,
    required this.workScheduleId,
    required this.effectiveFrom,
    required this.effectiveTo,
    required this.workSchedule,
    required this.scheduleOverrides,
  });

  @override
  List<Object?> get props => [
        id,
        employeeId,
        workScheduleId,
        effectiveFrom,
        effectiveTo,
        workSchedule,
        scheduleOverrides,
      ];
}

class WorkScheduleEntity extends Equatable {
  final int id;
  final String scheduleName;
  final String scheduleType;
  final String startTime;
  final String endTime;
  final int breakDurationMinutes;
  final int lateToleranceMinutes;
  final int earlyLeaveToleranceMinutes;
  final String status;

  const WorkScheduleEntity({
    required this.id,
    required this.scheduleName,
    required this.scheduleType,
    required this.startTime,
    required this.endTime,
    required this.breakDurationMinutes,
    required this.lateToleranceMinutes,
    required this.earlyLeaveToleranceMinutes,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        scheduleName,
        scheduleType,
        startTime,
        endTime,
        breakDurationMinutes,
        lateToleranceMinutes,
        earlyLeaveToleranceMinutes,
        status,
      ];
}

class ScheduleOverrideEntity extends Equatable {
  final String id;
  final String type;
  final String reason;
  final String status;
  final DateTime toDate;
  final DateTime fromDate;
  final DateTime createdAt;
  final int createdBy;
  final bool shiftCreated;
  final int? overrideWorkScheduleId;

  const ScheduleOverrideEntity({
    required this.id,
    required this.type,
    required this.reason,
    required this.status,
    required this.toDate,
    required this.fromDate,
    required this.createdAt,
    required this.createdBy,
    required this.shiftCreated,
    required this.overrideWorkScheduleId,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        reason,
        status,
        toDate,
        fromDate,
        createdAt,
        createdBy,
        shiftCreated,
        overrideWorkScheduleId,
      ];
}
