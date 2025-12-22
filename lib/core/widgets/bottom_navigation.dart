import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../routing/routes.dart';
import '../../faceid_channel.dart';
import '../../features/auth/providers/auth_providers.dart';
import '../../features/work_schedule/providers/work_schedule_providers.dart';
import '../services/shift_validation_service.dart';
import '../../flutter_flow/flutter_flow.dart';
import '../../flutter_flow/flutter_flow_util.dart';

class BottomNavigation extends ConsumerWidget {
  final int currentIndex;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = FlutterFlowTheme.of(context);
    
    return SizedBox(
      height: 54,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Custom Shape with Notch
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 70),
            painter: BottomNavBarPainter(
              backgroundColor: theme.secondaryBackground,
              shadowColor: Colors.black.withValues(alpha: 0.08),
            ),
          ),
          
          // Navigation Items
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 56,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    context,
                    theme,
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: 'Home',
                    index: 0,
                    onTap: () => _onItemTapped(context, ref, 0),
                  ),
                  _buildNavItem(
                    context,
                    theme,
                    icon: Icons.calendar_today_outlined,
                    activeIcon: Icons.calendar_today,
                    label: 'Schedule',
                    index: 1,
                    onTap: () => _onItemTapped(context, ref, 1),
                  ),
                  const SizedBox(width: 70), // Space for floating button
                  _buildNavItem(
                    context,
                    theme,
                    icon: Icons.event_note_outlined,
                    activeIcon: Icons.event_note,
                    label: 'Attendance',
                    index: 3,
                    onTap: () => _onItemTapped(context, ref, 3),
                  ),
                  _buildNavItem(
                    context,
                    theme,
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: 'Profile',
                    index: 4,
                    onTap: () => _onItemTapped(context, ref, 4),
                  ),
                ],
              ),
            ),
          ),

          // Floating Center Button
          Positioned(
            bottom: 25,
            child: GestureDetector(
              onTap: () => _onVerifyTapped(context, ref),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.face_retouching_natural,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    FlutterFlowTheme theme, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required VoidCallback onTap,
  }) {
    final isSelected = currentIndex == index;
    
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? theme.primaryColor : theme.secondaryText,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.bodyText2.override(
                color: isSelected ? theme.primaryColor : theme.secondaryText,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
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

    // Get today's shifts
    final scheduleState = ref.read(workScheduleControllerProvider);
    final now = DateTime.now();
    final todayShifts = scheduleState.shifts.where((s) {
      return s.shiftDate.year == now.year && 
             s.shiftDate.month == now.month && 
             s.shiftDate.day == now.day;
    }).toList();
    
    // Validate if there's a valid shift for check-in or check-out
    final validationResult = ShiftValidationService.validateCurrentShift(todayShifts);
    
    if (!validationResult.isValid) {
      // Show error dialog
      _showNoShiftDialog(context);
      return;
    }
    
    // Valid shift found, proceed with face verification
    FaceIdChannel.verifyFace(userId: userId);
  }
  
  void _showNoShiftDialog(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: theme.error,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'No Shift Found',
                style: theme.title3.override(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'No active shift available for check-in/check-out at this time.\n\n'
            'Please check your schedule and try again during your shift hours.',
            style: theme.bodyText1,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: theme.bodyText1.override(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
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
        context.go(AppRoutePath.attendanceReport);
        break;
      case 4:
        context.go(AppRoutePath.profile);
        break;
      default:
        break;
    }
  }
}

// Custom Painter for Bottom Navigation Bar with Notch
class BottomNavBarPainter extends CustomPainter {
  final Color backgroundColor;
  final Color shadowColor;

  BottomNavBarPainter({
    required this.backgroundColor,
    required this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final path = Path();
    
    final notchRadius = 32.0;
    final notchMargin = 6.0;
    
    // Start from bottom left
    path.moveTo(0, 20);
    
    // Left curve up
    path.lineTo(0, 0);
    
    // Calculate perfectly centered notch
    final notchCenterX = size.width / 2;
    final notchWidth = (notchRadius + notchMargin) * 2;
    final notchStartX = notchCenterX - notchWidth / 2;
    final notchEndX = notchCenterX + notchWidth / 2;
    
    // Top left to notch start
    path.lineTo(notchStartX, 0);
    
    // Small curve down to notch
    path.quadraticBezierTo(
      notchStartX + notchMargin / 2, 0,
      notchStartX + notchMargin, notchMargin / 2,
    );
    
    // Main circular arc (centered)
    path.arcToPoint(
      Offset(notchEndX - notchMargin, notchMargin / 2),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );
    
    // Small curve back up to top
    path.quadraticBezierTo(
      notchEndX - notchMargin / 2, 0,
      notchEndX, 0,
    );
    
    // Top right
    path.lineTo(size.width, 0);
    
    // Right side down
    path.lineTo(size.width, 15);
    path.lineTo(size.width, size.height);
    
    // Bottom
    path.lineTo(0, size.height);
    path.close();

    // Draw shadow
    canvas.drawPath(path, shadowPaint);
    
    // Draw main shape
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(BottomNavBarPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.shadowColor != shadowColor;
  }
}
