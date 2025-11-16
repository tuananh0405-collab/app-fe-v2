import 'user_entity.dart';

class LoginResponseEntity {
  final String accessToken;
  final String refreshToken;
  final UserEntity user;
  final bool mustChangePassword;

  const LoginResponseEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    this.mustChangePassword = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginResponseEntity &&
          runtimeType == other.runtimeType &&
          accessToken == other.accessToken &&
          refreshToken == other.refreshToken &&
          user == other.user &&
          mustChangePassword == other.mustChangePassword;

  @override
  int get hashCode =>
      accessToken.hashCode ^ refreshToken.hashCode ^ user.hashCode ^ mustChangePassword.hashCode;
}
