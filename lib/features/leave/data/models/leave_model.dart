import '../../domain/entities/leave_entity.dart';

class LeaveModel extends LeaveEntity {
  const LeaveModel({
    super.id,
    required super.employeeId,
    required super.employeeCode,
    required super.departmentId,
    required super.leaveTypeId,
    required super.startDate,
    required super.endDate,
    super.totalCalendarDays,
    super.totalWorkingDays,
    super.totalLeaveDays,
    required super.isHalfDayStart,
    required super.isHalfDayEnd,
    required super.reason,
    super.supportingDocumentUrl,
    super.status,
    super.requestedAt,
    super.approvalLevel,
    super.approvedAt,
    super.rejectionReason,
    super.cancelledAt,
    super.cancellationReason,
    super.metadata,
    super.createdAt,
    super.updatedAt,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      id: (json['id'] as num?)?.toInt(),
      employeeId: (json['employee_id'] as num).toInt(),
      employeeCode: json['employee_code'] as String,
      departmentId: (json['department_id'] as num).toInt(),
      leaveTypeId: (json['leave_type_id'] as num).toInt(),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      totalCalendarDays: (json['total_calendar_days'] as num?)?.toInt(),
      totalWorkingDays: (json['total_working_days'] as num?)?.toInt(),
      totalLeaveDays: (json['total_leave_days'] as num?)?.toDouble(),
      isHalfDayStart: json['is_half_day_start'] as bool? ?? false,
      isHalfDayEnd: json['is_half_day_end'] as bool? ?? false,
      reason: json['reason'] as String,
      supportingDocumentUrl: json['supporting_document_url'] as String?,
      status: json['status'] as String?,
      requestedAt: json['requested_at'] != null
          ? DateTime.parse(json['requested_at'] as String)
          : null,
      approvalLevel: (json['approval_level'] as num?)?.toInt(),
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null,
      rejectionReason: json['rejection_reason'] as String?,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      cancellationReason: json['cancellation_reason'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'employee_id': employeeId,
      'employee_code': employeeCode,
      'department_id': departmentId,
      'leave_type_id': leaveTypeId,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'is_half_day_start': isHalfDayStart,
      'is_half_day_end': isHalfDayEnd,
      'reason': reason,
      if (supportingDocumentUrl != null)
        'supporting_document_url': supportingDocumentUrl,
      if (metadata != null) 'metadata': metadata,
    };
  }
}
