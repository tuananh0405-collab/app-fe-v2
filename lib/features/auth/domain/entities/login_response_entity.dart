import 'user_entity.dart';

class LoginResponseEntity {
  final String accessToken;
  final String refreshToken;
  final UserEntity user;

  const LoginResponseEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginResponseEntity &&
          runtimeType == other.runtimeType &&
          accessToken == other.accessToken &&
          refreshToken == other.refreshToken &&
          user == other.user;

  @override
  int get hashCode =>
      accessToken.hashCode ^ refreshToken.hashCode ^ user.hashCode;
}
