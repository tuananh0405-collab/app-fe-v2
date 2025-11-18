import '../../domain/entities/overtime_entity.dart';

class OvertimeModel extends OvertimeEntity {
  const OvertimeModel({
    super.id,
    required super.employeeId,
    super.shiftId,
    required super.overtimeDate,
    required super.startTime,
    required super.endTime,
    required super.estimatedHours,
    super.actualHours,
    required super.reason,
    super.status,
    super.requestedAt,
    super.requestedBy,
    super.approvedBy,
    super.approvedAt,
    super.rejectionReason,
    super.createdAt,
    super.createdBy,
    super.updatedAt,
    super.updatedBy,
  });

  /// Helper method to parse double from either string or number
  static double _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    } else if (value is String) {
      return double.parse(value);
    }
    throw FormatException('Cannot parse $value to double');
  }

  /// Helper method to parse int from either string or number
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is num) {
      return value.toInt();
    } else if (value is String) {
      return int.parse(value);
    }
    throw FormatException('Cannot parse $value to int');
  }

  factory OvertimeModel.fromJson(Map<String, dynamic> json) {
    return OvertimeModel(
      id: _parseInt(json['id']),
      employeeId: _parseInt(json['employee_id'])!,
      shiftId: _parseInt(json['shift_id']),
      overtimeDate: DateTime.parse(json['overtime_date'] as String),
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      estimatedHours: _parseDouble(json['estimated_hours']),
      actualHours: json['actual_hours'] != null 
          ? _parseDouble(json['actual_hours']) 
          : null,
      reason: json['reason'] as String,
      status: json['status'] as String?,
      requestedAt: json['requested_at'] != null
          ? DateTime.parse(json['requested_at'] as String)
          : null,
      requestedBy: _parseInt(json['requested_by']),
      approvedBy: _parseInt(json['approved_by']),
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null,
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      createdBy: _parseInt(json['created_by']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      updatedBy: _parseInt(json['updated_by']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'employee_id': employeeId,
      if (shiftId != null) 'shift_id': shiftId,
      'overtime_date': overtimeDate.toIso8601String().split('T')[0],
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'estimated_hours': estimatedHours,
      'reason': reason,
    };
  }
}
