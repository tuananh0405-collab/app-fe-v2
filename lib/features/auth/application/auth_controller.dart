import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';

class AuthState {
  final bool isAuthenticated;
  const AuthState({required this.isAuthenticated});
  AuthState copyWith({bool? isAuthenticated}) =>
      AuthState(isAuthenticated: isAuthenticated ?? this.isAuthenticated);
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Watch login state to sync authentication
    final loginState = ref.watch(loginControllerProvider);
    return AuthState(isAuthenticated: loginState.isAuthenticated);
  }

  void signIn() {
    // This is now handled by LoginController
    // Keep this for backward compatibility with router
  }
  
  void signOut() {
    // Reset login state
    ref.read(loginControllerProvider.notifier).reset();
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
