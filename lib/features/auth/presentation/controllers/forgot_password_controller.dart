import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../providers/auth_providers.dart';
import '../state/forgot_password_state.dart';

class ForgotPasswordController extends Notifier<ForgotPasswordState> {
  late final ForgotPasswordUseCase _forgotPasswordUseCase;

  @override
  ForgotPasswordState build() {
    _forgotPasswordUseCase = ref.read(forgotPasswordUseCaseProvider);
    return const ForgotPasswordState();
  }

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isSuccess: false);

    final result = await _forgotPasswordUseCase(email);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
        );
      },
    );
  }

  void reset() {
    state = const ForgotPasswordState();
  }
}
