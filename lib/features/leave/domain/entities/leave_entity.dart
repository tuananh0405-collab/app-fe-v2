class LeaveEntity {
  final int? id;
  final int employeeId;
  final String employeeCode;
  final int departmentId;
  final int leaveTypeId;
  final DateTime startDate;
  final DateTime endDate;
  final int? totalCalendarDays;
  final int? totalWorkingDays;
  final double? totalLeaveDays;
  final bool isHalfDayStart;
  final bool isHalfDayEnd;
  final String reason;
  final String? supportingDocumentUrl;
  final String? status;
  final DateTime? requestedAt;
  final int? approvalLevel;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LeaveEntity({
    this.id,
    required this.employeeId,
    required this.employeeCode,
    required this.departmentId,
    required this.leaveTypeId,
    required this.startDate,
    required this.endDate,
    this.totalCalendarDays,
    this.totalWorkingDays,
    this.totalLeaveDays,
    required this.isHalfDayStart,
    required this.isHalfDayEnd,
    required this.reason,
    this.supportingDocumentUrl,
    this.status,
    this.requestedAt,
    this.approvalLevel,
    this.approvedAt,
    this.rejectionReason,
    this.cancelledAt,
    this.cancellationReason,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaveEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          employeeId == other.employeeId &&
          employeeCode == other.employeeCode;

  @override
  int get hashCode => id.hashCode ^ employeeId.hashCode ^ employeeCode.hashCode;
}
