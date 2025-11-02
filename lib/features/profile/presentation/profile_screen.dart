import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/application/auth_controller.dart';
import '../../../core/widgets/bottom_navigation.dart';
import '../../../core/routing/routes.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go(AppRoutePath.home);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(AppRoutePath.home),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Section
            _buildSectionHeader(context, 'Account'),
            _buildMenuItem(
              context: context,
              icon: Icons.person_outline,
              title: 'View Profile Details',
              subtitle: 'See your personal information',
              onTap: () => context.push(AppRoutePath.profileView),
            ),
            const SizedBox(height: 8),
            _buildMenuItem(
              context: context,
              icon: Icons.description_outlined,
              title: 'View Contract',
              subtitle: 'Employment contract details',
              onTap: () => context.push(AppRoutePath.profileContract),
            ),
            
            const SizedBox(height: 24),

            // Devices Section
            _buildSectionHeader(context, 'Devices & Security'),
            _buildMenuItem(
              context: context,
              icon: Icons.devices,
              title: 'Manage Devices',
              subtitle: 'View and manage registered devices',
              onTap: () => context.push(AppRoutePath.devices),
            ),
            const SizedBox(height: 8),
            _buildMenuItem(
              context: context,
              icon: Icons.face,
              title: 'Face ID Registration',
              subtitle: 'Register or update your Face ID',
              onTap: () => context.push(AppRoutePath.faceIdRegister),
            ),

            const SizedBox(height: 24),

            // Settings Section
            _buildSectionHeader(context, 'Settings'),
            _buildMenuItem(
              context: context,
              icon: Icons.lock_outline,
              title: 'Change Password',
              subtitle: 'Update your password',
              onTap: () {
                // TODO: Navigate to change password
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Coming soon')),
                );
              },
            ),
            const SizedBox(height: 8),
            _buildMenuItem(
              context: context,
              icon: Icons.notifications_outlined,
              title: 'Notification Settings',
              subtitle: 'Manage notification preferences',
              onTap: () => context.push(AppRoutePath.notificationsManage),
            ),

            const SizedBox(height: 24),

            // Logout Section
            _buildSectionHeader(context, 'Account Actions'),
            _buildMenuItem(
              context: context,
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Sign out of your account',
              iconColor: Colors.red,
              titleColor: Colors.red,
              onTap: () => _showLogoutDialog(context, ref),
            ),
          ],
        ),
        bottomNavigationBar: const BottomNavigation(currentIndex: 3),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? Theme.of(context).primaryColor)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor ?? Theme.of(context).primaryColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authControllerProvider.notifier).signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
