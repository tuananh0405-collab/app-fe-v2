class UserEntity {
  final String id;
  final String email;
  final String fullName;
  final String role;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          fullName == other.fullName &&
          role == other.role;

  @override
  int get hashCode =>
      id.hashCode ^ email.hashCode ^ fullName.hashCode ^ role.hashCode;
}
