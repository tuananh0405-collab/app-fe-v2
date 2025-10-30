import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <Map<String, String>>[
      {'title': 'Check Attendance', 'path': AppRoutePath.attendanceCheck},
      {'title': 'Attendance Report', 'path': AppRoutePath.attendanceReport},
      {'title': 'Create Leave', 'path': AppRoutePath.leavesCreate},
      {'title': 'Leave Detail (id=123)', 'path': AppRoutePath.leaveDetail('123')},
      {'title': 'Create Overtime', 'path': AppRoutePath.overtimesCreate},
      {'title': 'Overtime Detail (id=456)', 'path': AppRoutePath.overtimeDetail('456')},
      {'title': 'Notifications', 'path': AppRoutePath.notifications},
      {'title': 'Manage Notifications', 'path': AppRoutePath.notificationsManage},
      {'title': 'Profile Menu', 'path': AppRoutePath.profile},
      {'title': 'Profile View', 'path': AppRoutePath.profileView},
      {'title': 'Contract', 'path': AppRoutePath.profileContract},
      {'title': 'Devices', 'path': AppRoutePath.devices},
      {'title': 'Register Device', 'path': AppRoutePath.deviceRegister},
      {'title': 'Edit Device (id=xyz)', 'path': AppRoutePath.deviceEdit('xyz')},
      {'title': 'Register/Update FaceID', 'path': AppRoutePath.faceIdRegister},
      {'title': 'Schedule Management', 'path': AppRoutePath.schedule},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final it = items[i];
          return ElevatedButton(
            onPressed: () => context.go(it['path']!),
            child: Text(it['title']!),
          );
        },
      ),
    );
  }
}
