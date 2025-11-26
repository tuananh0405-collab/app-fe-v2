import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  ProfileModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.role,
    required super.status,
    super.employeeId,
    super.employeeCode,
    super.departmentId,
    super.departmentName,
    super.positionId,
    super.positionName,
    super.lastLoginAt,
    super.lastLoginIp,
    super.createdAt,
    super.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
      employeeId: json['employee_id'] as String?,
      employeeCode: json['employee_code'] as String?,
      departmentId: json['department_id'] as String?,
      departmentName: json['department_name'] as String?,
      positionId: json['position_id'] as String?,
      positionName: json['position_name'] as String?,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
      lastLoginIp: json['last_login_ip'] as String?,
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
      'email': email,
      'full_name': fullName,
      'role': role,
      'status': status,
      'employee_id': employeeId,
      'employee_code': employeeCode,
      'department_id': departmentId,
      'department_name': departmentName,
      'position_id': positionId,
      'position_name': positionName,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'last_login_ip': lastLoginIp,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
