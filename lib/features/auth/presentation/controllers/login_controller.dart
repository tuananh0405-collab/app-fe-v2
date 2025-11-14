import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/face_id_service.dart';
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
        
        // ✅ Lưu user info vào native SharedPreferences để Face ID sử dụng
        _saveUserInfoToNative(loginResponse);
      },
    );
  }

  /// Lưu user info vào native SharedPreferences (cho Face ID)
  Future<void> _saveUserInfoToNative(dynamic loginResponse) async {
    try {
      await FaceIdService.saveUserInfo(
        userId: loginResponse.user.id,
        userName: loginResponse.user.fullName,
        authToken: loginResponse.accessToken,
      );
      print('✅ User info saved to native: ${loginResponse.user.id}');
    } catch (e) {
      print('⚠️ Failed to save user info to native: $e');
    }
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


