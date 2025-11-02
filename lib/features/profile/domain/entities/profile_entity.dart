class ProfileEntity {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String status;
  final DateTime? lastLoginAt;

  ProfileEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.status,
    this.lastLoginAt,
  });
}
