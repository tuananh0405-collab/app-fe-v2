import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../routing/routes.dart';
import '../../faceid_channel.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../flutter_flow/flutter_flow_util.dart';

class BottomNavigation extends ConsumerWidget {
  final int currentIndex;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 100,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (index) => _onItemTapped(context, ref, index),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Colors.grey,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_outlined),
                  activeIcon: Icon(Icons.calendar_today),
                  label: 'Schedule',
                ),
                BottomNavigationBarItem(
                  icon: SizedBox(width: 40),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications_outlined),
                  activeIcon: Icon(Icons.notifications),
                  label: 'Notifications',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),

          // Floating Center Button
          Positioned(
            bottom: 20,
            child: GestureDetector(
              onTap: () => _onVerifyTapped(context, ref),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.face,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onVerifyTapped(BuildContext context, WidgetRef ref) {
    final loginState = ref.read(loginControllerProvider);
    final userId = loginState.user?.id;
    
    if (userId == null || userId.isEmpty) {
      showSnackbar(context, 'Please login first');
      return;
    }

    FaceIdChannel.verifyFace(userId: userId);
  }

  void _onItemTapped(BuildContext context, WidgetRef ref, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutePath.home);
        break;
      case 1:
        context.go(AppRoutePath.schedule);
        break;
      case 2:
        _onVerifyTapped(context, ref);
        break;
      case 3:
        context.go(AppRoutePath.notifications);
        break;
      case 4:
        context.go(AppRoutePath.profile);
        break;
      default:
        break;
    }
  }
}
