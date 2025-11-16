import '../../domain/entities/login_response_entity.dart';
import 'user_model.dart';

class LoginResponseModel extends LoginResponseEntity {
  const LoginResponseModel({
    required super.accessToken,
    required super.refreshToken,
    required super.user,
    super.mustChangePassword,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final mustChange = json['must_change_password'] as bool? ?? false;
    
    return LoginResponseModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      mustChangePassword: mustChange,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user': (user as UserModel).toJson(),
      'must_change_password': mustChangePassword,
    };
  }
}
