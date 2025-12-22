class ProfileEntity {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String status;
  final String? employeeId;
  final String? employeeCode;
  final String? departmentId;
  final String? departmentName;
  final String? positionId;
  final String? positionName;
  final DateTime? lastLoginAt;
  final String? lastLoginIp;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String? phone;
  final Map<String, dynamic>? address;
  final DateTime? dateOfBirth;
  ProfileEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.status,
    this.employeeId,
    this.employeeCode,
    this.departmentId,
    this.departmentName,
    this.positionId,
    this.positionName,
    this.lastLoginAt,
    this.lastLoginIp,
    this.createdAt,
    this.updatedAt,

    this.phone,
    this.address,
    this.dateOfBirth,
  });
}
