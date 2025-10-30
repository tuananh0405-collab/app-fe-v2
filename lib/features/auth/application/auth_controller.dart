import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isAuthenticated;
  const AuthState({required this.isAuthenticated});
  AuthState copyWith({bool? isAuthenticated}) =>
      AuthState(isAuthenticated: isAuthenticated ?? this.isAuthenticated);
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState(isAuthenticated: false);

  void signIn() => state = state.copyWith(isAuthenticated: true);
  void signOut() => state = state.copyWith(isAuthenticated: false);
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
