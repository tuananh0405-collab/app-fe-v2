import 'package:flutter_application_1/features/profile/presentation/profile_screen.dart';
import 'package:flutter_application_1/features/profile/presentation/profile_detail_screen.dart';
import 'package:flutter_application_1/features/notifications/presentation/pages/notifications_list_screen.dart';
import 'package:flutter_application_1/features/notification_preferences/presentation/pages/notification_preferences_screen.dart';
import 'package:flutter_application_1/features/leave/presentation/screens/leave_list_screen.dart';
import 'package:flutter_application_1/features/leave/presentation/screens/create_leave_screen.dart';
import 'package:flutter_application_1/features/leave/presentation/screens/leave_detail_screen.dart';
import 'package:flutter_application_1/features/leave/presentation/screens/update_leave_screen.dart';
import 'package:flutter_application_1/features/overtime/presentation/screens/overtime_list_screen.dart';
import 'package:flutter_application_1/features/overtime/presentation/screens/create_overtime_screen.dart';
import 'package:flutter_application_1/features/overtime/presentation/screens/overtime_detail_screen.dart';
import 'package:flutter_application_1/features/settings/presentation/settings_screen.dart';
import 'package:flutter_application_1/features/face_id/face_id_success_page.dart';
import 'package:flutter_application_1/features/devices/presentation/screens/device_list_screen.dart';
import 'package:flutter_application_1/features/work_schedule/presentation/screens/work_schedule_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/presentation/change_password_screen.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/common/presentation/stub_screen.dart';
import '../../faceid_page.dart';
import 'routes.dart';

// Tạo GoRouter trong Provider để lắng nghe auth state
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);
  final loginState = ref.watch(loginControllerProvider);

  return GoRouter(
    initialLocation: AppRoutePath.signIn,
    redirect: (context, state) {
      final currentPath = state.uri.path;
      final loggingIn = currentPath == AppRoutePath.signIn;
      final changingPassword = currentPath == AppRoutePath.changePassword;

      if (changingPassword) {
        return null;
      }

      if (loginState.mustChangePassword && !changingPassword) {
        return '${AppRoutePath.changePassword}?temporary=true';
      }

      if (!auth.isAuthenticated) {
        return loggingIn ? null : AppRoutePath.signIn;
      }

      if (loggingIn) {
        return AppRoutePath.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutePath.signIn,
        name: AppRouteName.signIn,
        builder: (context, state) => const SignInScreen(),
      ),

      GoRoute(
        path: AppRoutePath.changePassword,
        name: AppRouteName.changePassword,
        builder: (context, state) {
          final isTemporary = state.uri.queryParameters['temporary'] == 'true';
          return ChangePasswordScreen(isTemporary: isTemporary);
        },
      ),

      GoRoute(
        path: AppRoutePath.home,
        name: AppRouteName.home,
        builder: (context, state) => const HomeScreen(),
      ),

      GoRoute(
        path: AppRoutePath.attendanceCheck,
        name: AppRouteName.attendanceCheck,
        builder: (c, s) => const StubScreen(title: 'Check Attendance'),
      ),

      GoRoute(
        path: AppRoutePath.attendanceReport,
        name: AppRouteName.attendanceReport,
        builder: (c, s) =>
            const StubScreen(title: 'Personal Attendance Report'),
      ),

      GoRoute(
        path: '/leaves',
        name: 'leaves',
        builder: (c, s) => const LeaveListScreen(),
      ),

      GoRoute(
        path: AppRoutePath.leavesCreate,
        name: AppRouteName.leavesCreate,
        builder: (c, s) => const CreateLeaveScreen(),
      ),

      GoRoute(
        path: '/leaves/:id',
        name: AppRouteName.leaveDetail,
        builder: (c, s) {
          final id = s.pathParameters['id']!;
          return LeaveDetailScreen(leaveId: id);
        },
        routes: [
          GoRoute(
            path: 'edit',
            name: AppRouteName.leaveEdit,
            builder: (c, s) {
              final id = s.pathParameters['id']!;
              return UpdateLeaveScreen(leaveId: id);
            },
          ),
        ],
      ),

      // Overtimes
      GoRoute(
        path: '/overtimes',
        name: AppRouteName.overtimes,
        builder: (c, s) => const OvertimeListScreen(),
      ),

      GoRoute(
        path: '/overtimes/create',
        name: AppRouteName.overtimesCreate,
        builder: (c, s) => const CreateOvertimeScreen(),
      ),
      
      GoRoute(
        path: '/overtimes/:id',
        name: AppRouteName.overtimeDetail,
        builder: (c, s) {
          final id = s.pathParameters['id']!;
          return OvertimeDetailScreen(overtimeId: int.parse(id));
        },
        routes: [
          GoRoute(
            path: 'edit',
            name: AppRouteName.overtimeEdit,
            builder: (c, s) {
              final id = s.pathParameters['id']!;
              return StubScreen(
                title: 'Update Overtime Request',
                subtitle: 'id = $id',
              );
            },
          ),
        ],
      ),

      // Notifications
      GoRoute(
        path: AppRoutePath.notifications,
        name: AppRouteName.notifications,
        builder: (c, s) => const NotificationsListScreen(),
      ),
      GoRoute(
        path: AppRoutePath.notificationsManage,
        name: AppRouteName.notificationsManage,
        builder: (c, s) => const StubScreen(title: 'Manage Notifications'),
      ),
      GoRoute(
        path: AppRoutePath.notificationPreferences,
        name: AppRouteName.notificationPreferences,
        builder: (context, state) {
          // Get employee ID from login state
          final ref = ProviderScope.containerOf(context);
          final loginState = ref.read(loginControllerProvider);
          final employeeId = int.tryParse(loginState.user?.id ?? '0') ?? 0;
          
          return NotificationPreferencesScreen(employeeId: employeeId);
        },
      ),

      // Profile & Contract
      GoRoute(
        path: AppRoutePath.profile,
        name: AppRouteName.profile,
        builder: (c, s) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutePath.profileView,
        name: AppRouteName.profileView,
        builder: (c, s) => const ProfileDetailScreen(),
      ),
      GoRoute(
        path: AppRoutePath.profileContract,
        name: AppRouteName.profileContract,
        builder: (c, s) => const StubScreen(title: 'View Contract'),
      ),

      // Devices & FaceID
      GoRoute(
        path: AppRoutePath.devices,
        name: AppRouteName.devices,
        builder: (c, s) => const DeviceListScreen(),
      ),
      GoRoute(
        path: AppRoutePath.deviceRegister,
        name: AppRouteName.deviceRegister,
        builder: (c, s) => const StubScreen(title: 'Register Device'),
      ),
      GoRoute(
        path: '/devices/:id/edit',
        name: AppRouteName.deviceEdit,
        builder: (c, s) {
          final id = s.pathParameters['id']!;
          return StubScreen(title: 'Update Device', subtitle: 'id = $id');
        },
      ),
      GoRoute(
        path: AppRoutePath.faceIdRegister,
        name: AppRouteName.faceIdRegister,
        builder: (c, s) => const FaceIdPage(),
      ),
      GoRoute(
        path: AppRoutePath.faceIdSuccess,
        name: AppRouteName.faceIdSuccess,
        builder: (c, s) {
          final successMessage = s.uri.queryParameters['message'];
          final userName = s.uri.queryParameters['userName'];
          final action = s.uri.queryParameters['action'];
          return FaceIdSuccessPage(
            successMessage: successMessage,
            userName: userName,
            action: action,
          );
        },
      ),

      // Schedule
      GoRoute(
        path: AppRoutePath.schedule,
        name: AppRouteName.schedule,
        builder: (c, s) => const WorkScheduleScreen(),
      ),

      // Settings
      GoRoute(
        path: AppRoutePath.settings,
        name: AppRouteName.settings,
        builder: (c, s) => const SettingsScreen(),
      ),
    ],
  );
});
