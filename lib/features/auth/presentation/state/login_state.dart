import '../../domain/entities/user_entity.dart';

class LoginState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? errorMessage;
  final bool isTemporaryPassword;
  final String? accessToken;
  final String? refreshToken;
  final UserEntity? user;

  const LoginState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.errorMessage,
    this.isTemporaryPassword = false,
    this.accessToken,
    this.refreshToken,
    this.user,
  });

  LoginState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? errorMessage,
    bool? isTemporaryPassword,
    String? accessToken,
    String? refreshToken,
    UserEntity? user,
    bool clearError = false,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isTemporaryPassword: isTemporaryPassword ?? this.isTemporaryPassword,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      user: user ?? this.user,
    );
  }
}
