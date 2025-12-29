import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

/// GPS & Battery Permission Helper
/// 
/// Handles all permission requests needed for background GPS tracking
class GpsPermissionHelper {
  /// Check if all required permissions are granted
  static Future<bool> hasAllPermissions() async {
    if (!Platform.isAndroid) return true;

    final locationStatus = await Geolocator.checkPermission();
    
    return locationStatus == LocationPermission.always;
  }

  /// Request all required permissions with user-friendly dialogs
  static Future<bool> requestAllPermissions(BuildContext context) async {
    if (!Platform.isAndroid) return true;

    // Step 1: Location Permission
    final locationGranted = await _requestLocationPermission(context);
    if (!locationGranted) return false;

    // Step 2: Battery Optimization (Optional but recommended)
    await _requestBatteryOptimization(context);

    return true;
  }

  /// Request location permission (Always Allow)
  static Future<bool> _requestLocationPermission(BuildContext context) async {
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        await _showPermissionDeniedDialog(context);
      }
      return false;
    }

    // If only "While Using App", prompt to upgrade to "Always Allow"
    if (permission == LocationPermission.whileInUse) {
      if (context.mounted) {
        final shouldUpgrade = await _showAlwaysAllowDialog(context);
        if (shouldUpgrade) {
          permission = await Geolocator.requestPermission();
        }
      }
    }

    return permission == LocationPermission.always;
  }

  /// Request battery optimization exemption
  static Future<bool> _requestBatteryOptimization(BuildContext context) async {
    try {
      final status = await Permission.ignoreBatteryOptimizations.status;
      
      if (status.isDenied) {
        if (context.mounted) {
          final shouldRequest = await _showBatteryOptimizationDialog(context);
          if (shouldRequest) {
            final result = await Permission.ignoreBatteryOptimizations.request();
            return result.isGranted;
          }
        }
      }
      
      return status.isGranted;
    } catch (e) {
      debugPrint('❌ Battery optimization request failed: $e');
      return false;
    }
  }

  /// Dialog: Location Permission Permanently Denied
  static Future<void> _showPermissionDeniedDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Location Permission Required'),
        content: const Text(
          'Background GPS tracking requires location permission.\n\n'
          'Please enable it in Settings:\n'
          '1. Go to App Info\n'
          '2. Tap Permissions\n'
          '3. Tap Location\n'
          '4. Select "Allow all the time"',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Geolocator.openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Dialog: Request "Always Allow" Location
  static Future<bool> _showAlwaysAllowDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📍 Background GPS Tracking'),
        content: const Text(
          'To track your location in the background, we need "Always Allow" permission.\n\n'
          'This allows the app to verify your attendance even when the app is closed.\n\n'
          'Your privacy is protected - location is only checked during work hours.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Dialog: Request Battery Optimization Exemption
  static Future<bool> _showBatteryOptimizationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔋 Battery Optimization'),
        content: const Text(
          'For reliable background GPS tracking, we recommend disabling battery optimization for this app.\n\n'
          'This ensures the app can track your location even when your device is in sleep mode.\n\n'
          'Note: This will have minimal impact on your battery life.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Allow'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Get permission status summary
  static Future<Map<String, bool>> getPermissionStatus() async {
    if (!Platform.isAndroid) {
      return {
        'location_always': true,
        'battery_optimization': true,
      };
    }

    final locationStatus = await Geolocator.checkPermission();
    final batteryStatus = await Permission.ignoreBatteryOptimizations.status;

    return {
      'location_always': locationStatus == LocationPermission.always,
      'location_while_in_use': locationStatus == LocationPermission.whileInUse,
      'battery_optimization': batteryStatus.isGranted,
    };
  }

  /// Show comprehensive permission status
  static Future<void> showPermissionStatusDialog(BuildContext context) async {
    final status = await getPermissionStatus();
    
    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('📋 Permission Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusRow(
              '📍 Location (Always)',
              status['location_always'] ?? false,
            ),
            const SizedBox(height: 8),
            _buildStatusRow(
              '🔋 Battery Optimization',
              status['battery_optimization'] ?? false,
            ),
            const SizedBox(height: 16),
            if (!(status['location_always'] ?? false))
              const Text(
                '⚠️ Background GPS requires "Always Allow" location permission.',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        actions: [
          if (!(status['location_always'] ?? false) || 
              !(status['battery_optimization'] ?? false))
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Geolocator.openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static Widget _buildStatusRow(String label, bool granted) {
    return Row(
      children: [
        Icon(
          granted ? Icons.check_circle : Icons.cancel,
          color: granted ? Colors.green : Colors.red,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: granted ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
