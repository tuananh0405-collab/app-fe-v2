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
    super.phone,
    super.address,
    super.dateOfBirth,
  });

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is String && v.trim().isNotEmpty) return DateTime.tryParse(v);
    return null;
  }

  ProfileModel copyWith({
    String? departmentId,
    String? departmentName,
    String? positionId,
    String? positionName,
    String? phone,
    DateTime? dateOfBirth,
    Map<String, dynamic>? address,
  }) {
    return ProfileModel(
      id: id,
      email: email,
      fullName: fullName,
      role: role,
      status: status,
      employeeId: employeeId,
      employeeCode: employeeCode,

      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      positionId: positionId ?? this.positionId,
      positionName: positionName ?? this.positionName,

      lastLoginAt: lastLoginAt,
      lastLoginIp: lastLoginIp,
      createdAt: createdAt,
      updatedAt: updatedAt,

      phone: phone ?? this.phone,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      role: json['role'] as String,
      status: json['status'] as String,
      employeeId: json['employee_id']?.toString(),
      employeeCode: json['employee_code'] as String?,
      departmentId: json['department_id']?.toString(),
      departmentName: json['department_name'] as String?,
      positionId: json['position_id']?.toString(),
      positionName: json['position_name'] as String?,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.tryParse(json['last_login_at'] as String)
          : null,
      lastLoginIp: json['last_login_ip'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,

      phone: json['phone'] as String?,
      address: (json['address'] is Map)
          ? Map<String, dynamic>.from(json['address'] as Map)
          : null,

      dateOfBirth: _parseDate(json['dateOfBirth'] ?? json['date_of_birth']),
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
      'phone': phone,
      'address': address,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
    };
  }
}
