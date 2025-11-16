import 'package:flutter/material.dart';
import '../../core/di/injection_container.dart' as di;
import '../../core/services/push_notification_manager.dart';

/// Example: How to unregister push token when user logs out
/// 
/// Thêm code này vào logout logic của bạn
class LogoutExample {
  
  /// Example 1: Simple logout với unregister push token
  Future<void> logout(BuildContext context) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // Unregister push token trước khi logout
      final pushManager = di.sl<PushNotificationManager>();
      await pushManager.unregisterPushToken();
      
      // TODO: Clear local auth data (token, user info, etc.)
      // await authRepository.logout();
      // await secureStorage.deleteAll();
      
      // Navigate to login
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading
        // Navigator.of(context).pushReplacementNamed('/login');
        // or use GoRouter: context.go('/login');
      }
      
      debugPrint('Logged out successfully and unregistered push token');
    } catch (e) {
      debugPrint('Error during logout: $e');
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout error: $e')),
        );
      }
    }
  }

  /// Example 2: Logout với confirmation dialog
  Future<void> logoutWithConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await logout(context);
    }
  }
}

/// Example: Settings screen với logout button
class SettingsScreenExample extends StatelessWidget {
  const SettingsScreenExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // ... other settings ...
          
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              final pushManager = di.sl<PushNotificationManager>();
              await pushManager.unregisterPushToken();
              
              // TODO: Add your logout logic here
              if (context.mounted) {
                // Navigate to login
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Example: Riverpod provider cho logout
/// 
/// Nếu bạn dùng Riverpod, có thể tạo provider như này:
/*
final logoutUseCaseProvider = Provider((ref) {
  return LogoutUseCase(
    authRepository: ref.read(authRepositoryProvider),
    pushManager: di.sl<PushNotificationManager>(),
  );
});

class LogoutUseCase {
  final AuthRepository authRepository;
  final PushNotificationManager pushManager;

  LogoutUseCase({
    required this.authRepository,
    required this.pushManager,
  });

  Future<void> execute() async {
    // Unregister push token
    await pushManager.unregisterPushToken();
    
    // Clear auth data
    await authRepository.logout();
  }
}

// Trong UI:
final logout = ref.read(logoutUseCaseProvider);
await logout.execute();
*/
