import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/routing/routes.dart';
import '../../../../flutter_flow/flutter_flow.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      // Navigate to signIn, the router's redirect logic will handle 
      // redirecting to home if already authenticated
      context.go(AppRoutePath.signIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ffTheme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: ffTheme.primaryBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: ffTheme.primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ffTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.access_time_filled_rounded,
                size: 60,
                color: ffTheme.info,
              ),
            ).animate()
             .scale(duration: 600.ms, curve: Curves.easeOutBack)
             .fadeIn(duration: 600.ms),
            
            const SizedBox(height: 24),
            
            Text(
              'Employee App',
              style: ffTheme.title1.copyWith(
                color: ffTheme.primaryText,
                fontWeight: FontWeight.bold,
              ),
            ).animate()
             .fadeIn(delay: 400.ms, duration: 600.ms)
             .moveY(begin: 20, end: 0, delay: 400.ms, duration: 600.ms),

            const SizedBox(height: 12),

            Text(
              'Manage your work efficiently',
              style: ffTheme.bodyText1.copyWith(
                color: ffTheme.secondaryText,
              ),
            ).animate()
             .fadeIn(delay: 800.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }
}
