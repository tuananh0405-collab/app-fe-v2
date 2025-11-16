import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/change_temporary_password_usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../providers/auth_providers.dart';
import '../state/change_password_state.dart';

class ChangePasswordController extends Notifier<ChangePasswordState> {
  late final ChangeTemporaryPasswordUseCase _changeTemporaryPasswordUseCase;
  late final ChangePasswordUseCase _changePasswordUseCase;

  @override
  ChangePasswordState build() {
    _changeTemporaryPasswordUseCase = ref.read(
      changeTemporaryPasswordUseCaseProvider,
    );
    _changePasswordUseCase = ref.read(changePasswordUseCaseProvider);
    return const ChangePasswordState();
  }

  Future<void> changeTemporaryPassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _changeTemporaryPasswordUseCase(
      ChangeTemporaryPasswordParams(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (_) {
        state = state.copyWith(isLoading: false, isSuccess: true);
      },
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _changePasswordUseCase(
      ChangePasswordParams(
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (_) {
        state = state.copyWith(isLoading: false, isSuccess: true);
      },
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void reset() {
    state = const ChangePasswordState();
  }
}
