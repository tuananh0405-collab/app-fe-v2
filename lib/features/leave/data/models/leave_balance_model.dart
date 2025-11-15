import '../../domain/entities/leave_balance_entity.dart';

class LeaveBalanceModel extends LeaveBalanceEntity {
  const LeaveBalanceModel({
    required super.id,
    required super.employeeId,
    required super.leaveTypeId,
    required super.leaveTypeName,
    required super.totalDays,
    required super.usedDays,
    required super.remainingDays,
    required super.year,
    super.createdAt,
    super.updatedAt,
  });

  factory LeaveBalanceModel.fromJson(Map<String, dynamic> json) {
    return LeaveBalanceModel(
      id: (json['id'] as num).toInt(),
      employeeId: (json['employee_id'] as num).toInt(),
      leaveTypeId: (json['leave_type_id'] as num).toInt(),
      leaveTypeName: json['leave_type_name'] as String,
      totalDays: (json['total_days'] as num).toDouble(),
      usedDays: (json['used_days'] as num).toDouble(),
      remainingDays: (json['remaining_days'] as num).toDouble(),
      year: (json['year'] as num).toInt(),
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
      'id': id,
      'employee_id': employeeId,
      'leave_type_id': leaveTypeId,
      'leave_type_name': leaveTypeName,
      'total_days': totalDays,
      'used_days': usedDays,
      'remaining_days': remainingDays,
      'year': year,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}
