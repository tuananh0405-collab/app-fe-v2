import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/background_gps_service.dart';
import '../../../core/utils/gps_permission_helper.dart';
import '../../../flutter_flow/flutter_flow.dart';

/// Provider for GPS Background Tracking Settings
final gpsBackgroundEnabledProvider = StateNotifierProvider<GpsBackgroundEnabledNotifier, bool>((ref) {
  return GpsBackgroundEnabledNotifier(ref);
});

class GpsBackgroundEnabledNotifier extends StateNotifier<bool> {
  final Ref ref;
  
  GpsBackgroundEnabledNotifier(this.ref) : super(false) {
    _loadSetting();
  }

  Future<void> _loadSetting() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('gps_background_enabled') ?? false;
    
    // Auto-start if enabled
    if (state) {
      await BackgroundGpsService.startPeriodicSync();
    }
  }

  Future<void> setEnabled(bool enabled) async {
    if (enabled) {
      // Check permissions first
      final hasPermissions = await GpsPermissionHelper.hasAllPermissions();
      if (!hasPermissions) {
        // Request permissions will be handled by the UI
        return;
      }
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('gps_background_enabled', enabled);
    state = enabled;
    
    if (enabled) {
      await BackgroundGpsService.startPeriodicSync(
        frequency: const Duration(minutes: 30), // Sync every 30 minutes
      );
    } else {
      await BackgroundGpsService.stopPeriodicSync();
    }
  }
}

/// GPS Background Tracking Settings Screen
class GpsBackgroundSettingsScreen extends ConsumerWidget {
  const GpsBackgroundSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = FlutterFlowTheme.of(context);
    final isEnabled = ref.watch(gpsBackgroundEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Background Tracking'),
        backgroundColor: theme.primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.lineColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: theme.primaryColor,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Background GPS Tracking',
                            style: theme.title3,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isEnabled ? 'Active' : 'Inactive',
                            style: theme.bodyText2.override(
                              fontFamily: 'Readex Pro',
                              color: isEnabled ? Colors.green : Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Enable/Disable Switch
          Card(
            elevation: 2,
            child: SwitchListTile(
              title: Text(
                'Enable Background GPS',
                style: theme.subtitle1,
              ),
              subtitle: Text(
                isEnabled 
                  ? 'Your location is being tracked every 30 minutes'
                  : 'Enable to track your location in the background',
                style: theme.bodyText2,
              ),
              value: isEnabled,
              onChanged: (value) async {
                if (value) {
                  // Check and request permissions
                  final hasPermissions = await GpsPermissionHelper.requestAllPermissions(context);
                  if (!hasPermissions) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('⚠️ Required permissions not granted'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    return;
                  }
                }
                
                await ref.read(gpsBackgroundEnabledProvider.notifier).setEnabled(value);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value 
                          ? '✅ Background GPS tracking enabled'
                          : '🛑 Background GPS tracking disabled',
                      ),
                      backgroundColor: value ? Colors.green : Colors.orange,
                    ),
                  );
                }
              },
            ),
          ),

          const SizedBox(height: 16),

          // Information Section
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: theme.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'How it works',
                        style: theme.subtitle1,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoItem(
                    theme,
                    '⏰',
                    'Automatic Tracking',
                    'GPS is checked every 30 minutes automatically',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoItem(
                    theme,
                    '📍',
                    'Location Accuracy',
                    'Uses high-accuracy GPS for precise location',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoItem(
                    theme,
                    '🔋',
                    'Battery Optimized',
                    'Minimal battery usage with smart sync intervals',
                  ),
                  const SizedBox(height: 8),
                  _buildInfoItem(
                    theme,
                    '🔒',
                    'Privacy & Security',
                    'Location data is encrypted and stored securely',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Requirements Section
          Card(
            elevation: 1,
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        'Requirements',
                        style: theme.subtitle1.override(
                          fontFamily: 'Readex Pro',
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Location permission must be set to "Allow all the time"\n'
                    '• Location services must be enabled\n'
                    '• Internet connection required for syncing\n'
                    '• Battery optimization should be disabled for this app',
                    style: theme.bodyText2.override(
                      fontFamily: 'Readex Pro',
                      color: Colors.orange.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Actions
          ElevatedButton.icon(
            onPressed: () async {
              await GpsPermissionHelper.showPermissionStatusDialog(context);
            },
            icon: const Icon(Icons.info_outline),
            label: const Text('Check Permissions'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),

          const SizedBox(height: 12),

          if (isEnabled) ...[
            ElevatedButton.icon(
              onPressed: () async {
                // Trigger manual sync
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🔄 Syncing GPS location...'),
                  ),
                );
                
                // Force a sync now
                await BackgroundGpsService.stopPeriodicSync();
                await BackgroundGpsService.startPeriodicSync();
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ GPS sync completed'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.sync),
              label: const Text('Sync Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    FlutterFlowTheme theme,
    String emoji,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.bodyText1.override(
                  fontFamily: 'Readex Pro',
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: theme.bodyText2.override(
                  fontFamily: 'Readex Pro',
                  color: theme.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
