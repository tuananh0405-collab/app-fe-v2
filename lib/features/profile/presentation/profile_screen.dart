import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/application/auth_controller.dart';
import '../../../core/widgets/bottom_navigation.dart';
import '../../../core/routing/routes.dart';
import '../../../flutter_flow/flutter_flow.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin, AnimationControllerMixin<ProfileScreen> {
  
  @override
  void initState() {
    super.initState();
    
    // Setup animations
    setupAnimations({
      'listOnPageLoad': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effects: FFAnimations.fadeInSlideUp(
          delay: const Duration(milliseconds: 100),
          duration: const Duration(milliseconds: 600),
        ),
      ),
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go(AppRoutePath.home);
        }
      },
      child: Scaffold(
        backgroundColor: theme.primaryBackground,
        appBar: AppBar(
          title: Text(
            'Profile',
            style: theme.title2.override(color: Colors.white),
          ),
          centerTitle: true,
          elevation: 2,
          backgroundColor: theme.primaryColor,
          iconTheme: IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(AppRoutePath.home),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Section
            _buildSectionHeader(context, theme, 'Account'),
            _buildMenuItem(
              context: context,
              theme: theme,
              icon: Icons.person_outline,
              title: 'View Profile Details',
              subtitle: 'See your personal information',
              onTap: () => context.push(AppRoutePath.profileView),
            ),
            const SizedBox(height: 8),
            _buildMenuItem(
              context: context,
              theme: theme,
              icon: Icons.description_outlined,
              title: 'View Contract',
              subtitle: 'Employment contract details',
              onTap: () => context.push(AppRoutePath.profileContract),
            ),
            
            const SizedBox(height: 24),

            // Devices Section
            _buildSectionHeader(context, theme, 'Devices & Security'),
            _buildMenuItem(
              context: context,
              theme: theme,
              icon: Icons.devices,
              title: 'Manage Devices',
              subtitle: 'View and manage registered devices',
              onTap: () => context.push(AppRoutePath.devices),
            ),
            const SizedBox(height: 8),
            _buildMenuItem(
              context: context,
              theme: theme,
              icon: Icons.face,
              title: 'Face ID Registration',
              subtitle: 'Register or update your Face ID',
              onTap: () => context.push(AppRoutePath.faceIdRegister),
            ),

            const SizedBox(height: 24),

            // Settings Section
            _buildSectionHeader(context, theme, 'Settings'),
            _buildMenuItem(
              context: context,
              theme: theme,
              icon: Icons.lock_outline,
              title: 'Change Password',
              subtitle: 'Update your password',
              onTap: () {
                // TODO: Navigate to change password
                showSnackbar(context, 'Coming soon');
              },
            ),
            const SizedBox(height: 8),
            _buildMenuItem(
              context: context,
              theme: theme,
              icon: Icons.notifications_outlined,
              title: 'Notification Settings',
              subtitle: 'Manage notification preferences',
              onTap: () => context.push(AppRoutePath.notificationsManage),
            ),

            const SizedBox(height: 24),

            // Logout Section
            _buildSectionHeader(context, theme, 'Account Actions'),
            _buildMenuItem(
              context: context,
              theme: theme,
              icon: Icons.logout,
              title: 'Logout',
              subtitle: 'Sign out of your account',
              iconColor: theme.error,
              titleColor: theme.error,
              onTap: () => _showLogoutDialog(context),
            ),
          ],
        ),
        bottomNavigationBar: const BottomNavigation(currentIndex: 3),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, FlutterFlowTheme theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        title,
        style: theme.subtitle2.override(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required FlutterFlowTheme theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    final effectiveIconColor = iconColor ?? theme.primaryColor;
    
    return Card(
      elevation: 1,
      color: theme.secondaryBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: effectiveIconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: effectiveIconColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: theme.bodyText1.override(
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.bodyText2,
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.secondaryText,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.secondaryBackground,
        title: Text('Logout', style: theme.title3),
        content: Text(
          'Are you sure you want to logout?',
          style: theme.bodyText1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: theme.bodyText1.override(
                color: theme.secondaryText,
              ),
            ),
          ),
          FFButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ref.read(authControllerProvider.notifier).signOut();
            },
            text: 'Logout',
            options: FFButtonOptions(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              color: theme.error,
              textStyle: theme.bodyText1.override(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}
