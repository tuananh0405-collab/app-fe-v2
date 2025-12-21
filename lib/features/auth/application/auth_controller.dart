import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../providers/auth_providers.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isInitialized;
  const AuthState({
    required this.isAuthenticated,
    this.isInitialized = false,
  });
  AuthState copyWith({bool? isAuthenticated, bool? isInitialized}) =>
      AuthState(
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        isInitialized: isInitialized ?? this.isInitialized,
      );
}

class AuthController extends Notifier<AuthState> {
  bool _hasAttemptedRestore = false;

  @override
  AuthState build() {
    // Watch login state to sync authentication
    final loginState = ref.watch(loginControllerProvider);
    
    // Attempt to restore session only once on first build
    if (!_hasAttemptedRestore) {
      _hasAttemptedRestore = true;
      // Schedule restoration after build completes
      Future.microtask(() => _restoreSession());
    }
    
    return AuthState(
      isAuthenticated: loginState.isAuthenticated,
      isInitialized: _hasAttemptedRestore,
    );
  }

  /// Khôi phục session từ Hive storage khi app khởi động
  Future<void> _restoreSession() async {
    try {
      debugPrint('🔄 Attempting to restore session from storage...');
      
      final box = await Hive.openBox('auth');
      final accessToken = box.get('accessToken') as String?;
      final refreshToken = box.get('refreshToken') as String?;
      
      if (accessToken != null && refreshToken != null) {
        debugPrint('Found saved tokens, restoring session...');
        
        // Restore session through LoginController
        await ref.read(loginControllerProvider.notifier).restoreSession(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
        
        debugPrint('Session restored successfully');
      } else {
        debugPrint('ℹ️ No saved session found');
      }
    } catch (e) {
      debugPrint('Failed to restore session: $e');
    }
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
