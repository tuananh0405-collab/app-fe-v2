import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/services/face_id_service.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../providers/auth_providers.dart';
import '../state/login_state.dart';
import 'package:flutter/foundation.dart';
class LoginController extends Notifier<LoginState> {
  late final LoginUseCase _loginUseCase;

  @override
  LoginState build() {
    _loginUseCase = ref.read(loginUseCaseProvider);
    return const LoginState();
  }

  Future<void> login(String email, String password) async {
    // Reset state trước khi login để đảm bảo listener hoạt động đúng
    state = const LoginState();
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
        final newState = LoginState(
          isLoading: false,
          isAuthenticated: !loginResponse.mustChangePassword,
          mustChangePassword: loginResponse.mustChangePassword,
          accessToken: loginResponse.accessToken,
          refreshToken: loginResponse.refreshToken,
          user: loginResponse.user,
        );
        
        state = newState;
        
        debugPrint('🔍 State updated: mustChangePassword=${state.mustChangePassword}, isAuthenticated=${state.isAuthenticated}');
        
        //  Lưu user info vào native SharedPreferences để Face ID sử dụng
        if (!loginResponse.mustChangePassword) {
          _saveUserInfoToNative(loginResponse);
        }
      },
    );
  }

  /// Lưu user info vào native SharedPreferences (cho Face ID) và Hive (cho background handlers)
  Future<void> _saveUserInfoToNative(dynamic loginResponse) async {
    try {
      // Save to native SharedPreferences for Face ID
      await FaceIdService.saveUserInfo(
        userId: loginResponse.user.id,
        employeeId: loginResponse.user.employeeId,
        userName: loginResponse.user.fullName,
        authToken: loginResponse.accessToken,
        refreshToken: loginResponse.refreshToken,
      );
      
      // Save to Hive for background handlers (e.g., push notifications)
      await _saveTokensToHive(
        accessToken: loginResponse.accessToken,
        refreshToken: loginResponse.refreshToken,
      );
    } catch (e) {
      debugPrint('⚠️ Failed to save user info to native: $e');
    }
  }
  
  /// Lưu tokens vào Hive để background handlers có thể truy cập
  Future<void> _saveTokensToHive({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      final box = await Hive.openBox('auth');
      await box.put('accessToken', accessToken);
      await box.put('refreshToken', refreshToken);
      debugPrint('✅ Saved tokens to Hive');
    } catch (e) {
      debugPrint('❌ Failed to save tokens to Hive: $e');
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
    // Also update native storage and Hive so background handlers can use the latest tokens
    try {
      FaceIdService.saveUserInfo(
        userId: state.user?.id ?? '',
        userName: state.user?.fullName ?? '',
        authToken: accessToken,
        refreshToken: refreshToken,
      );
      
      // Update Hive as well
      _saveTokensToHive(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } catch (_) {}
  }

  void reset() {
    state = const LoginState();
    
    // Clear tokens from Hive
    try {
      Hive.openBox('auth').then((box) {
        box.delete('accessToken');
        box.delete('refreshToken');
        debugPrint('✅ Cleared tokens from Hive');
      });
    } catch (e) {
      debugPrint('❌ Failed to clear tokens from Hive: $e');
    }
  }
}


