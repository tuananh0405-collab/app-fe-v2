import 'package:flutter_application_1/features/profile/presentation/profile_screen.dart';
import 'package:flutter_application_1/features/profile/presentation/profile_detail_screen.dart';
import 'package:flutter_application_1/features/notifications/presentation/pages/notifications_list_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/common/presentation/stub_screen.dart';
import 'routes.dart';

// Tạo GoRouter trong Provider để lắng nghe auth state
final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: AppRoutePath.signIn,
    redirect: (context, state) {
      final loggingIn = state.matchedLocation == AppRoutePath.signIn;
      if (!auth.isAuthenticated) {
        // Chưa login → luôn về /sign-in trừ khi đã ở đó
        return loggingIn ? null : AppRoutePath.signIn;
      }
      // Đã login mà đang ở /sign-in → đẩy về /home
      if (loggingIn) return AppRoutePath.home;
      return null;
    },
    routes: [
      // Sign in (không cần guard)
      GoRoute(
        path: AppRoutePath.signIn,
        name: AppRouteName.signIn,
        builder: (context, state) => const SignInScreen(),
      ),

      // Các route sau mặc định đã được guard bởi redirect ở trên
      GoRoute(
        path: AppRoutePath.home,
        name: AppRouteName.home,
        builder: (context, state) => const HomeScreen(),
      ),

      // Attendance
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

      // Leaves
      GoRoute(
        path: AppRoutePath.leavesCreate,
        name: AppRouteName.leavesCreate,
        builder: (c, s) => const StubScreen(title: 'Create Leave Request'),
      ),
      GoRoute(
        path: '/leaves/:id',
        name: AppRouteName.leaveDetail,
        builder: (c, s) {
          final id = s.pathParameters['id']!;
          return StubScreen(title: 'Leave Detail', subtitle: 'id = $id');
        },
        routes: [
          GoRoute(
            path: 'edit',
            name: AppRouteName.leaveEdit,
            builder: (c, s) {
              final id = s.pathParameters['id']!;
              return StubScreen(
                title: 'Update Leave Request',
                subtitle: 'id = $id',
              );
            },
          ),
        ],
      ),

      // Overtimes
      GoRoute(
        path: AppRoutePath.overtimesCreate,
        name: AppRouteName.overtimesCreate,
        builder: (c, s) => const StubScreen(title: 'Create Overtime Request'),
      ),
      GoRoute(
        path: '/overtimes/:id',
        name: AppRouteName.overtimeDetail,
        builder: (c, s) {
          final id = s.pathParameters['id']!;
          return StubScreen(title: 'Overtime Detail', subtitle: 'id = $id');
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
        builder: (c, s) => const StubScreen(title: 'Manage Devices'),
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
        builder: (c, s) => const StubScreen(title: 'Register & Update FaceID'),
      ),

      // Schedule
      GoRoute(
        path: AppRoutePath.schedule,
        name: AppRouteName.schedule,
        builder: (c, s) => const StubScreen(title: 'Schedule Management'),
      ),
    ],
  );
});
