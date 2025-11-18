class OvertimeEntity {
  final int? id;
  final int employeeId;
  final int? shiftId;
  final DateTime overtimeDate;
  final DateTime startTime;
  final DateTime endTime;
  final double estimatedHours;
  final double? actualHours;
  final String reason;
  final String? status;
  final DateTime? requestedAt;
  final int? requestedBy;
  final int? approvedBy;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final DateTime? createdAt;
  final int? createdBy;
  final DateTime? updatedAt;
  final int? updatedBy;

  const OvertimeEntity({
    this.id,
    required this.employeeId,
    this.shiftId,
    required this.overtimeDate,
    required this.startTime,
    required this.endTime,
    required this.estimatedHours,
    this.actualHours,
    required this.reason,
    this.status,
    this.requestedAt,
    this.requestedBy,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OvertimeEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          employeeId == other.employeeId;

  @override
  int get hashCode => id.hashCode ^ employeeId.hashCode;
}
