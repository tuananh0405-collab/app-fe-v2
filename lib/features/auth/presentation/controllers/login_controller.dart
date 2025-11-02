import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../providers/auth_providers.dart';
import '../state/login_state.dart';

class LoginController extends Notifier<LoginState> {
  late final LoginUseCase _loginUseCase;

  @override
  LoginState build() {
    _loginUseCase = ref.read(loginUseCaseProvider);
    return const LoginState();
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _loginUseCase(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          isTemporaryPassword: failure.runtimeType.toString().contains('TemporaryPasswordFailure'),
        );
      },
      (loginResponse) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          accessToken: loginResponse.accessToken,
          refreshToken: loginResponse.refreshToken,
          user: loginResponse.user,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // Update tokens after refresh
  void updateTokens({
    required String accessToken,
    required String refreshToken,
  }) {
    state = state.copyWith(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  void reset() {
    state = const LoginState();
  }
}


