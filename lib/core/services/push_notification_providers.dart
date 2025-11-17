import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/common_providers.dart';
import '../network/dio_client.dart';
import '../network/push_notification_api.dart';
import 'push_notification_service.dart';
import 'push_notification_manager.dart';

/// Provider for push notification enabled setting
final pushNotificationEnabledProvider = NotifierProvider<PushNotificationEnabledNotifier, bool>(PushNotificationEnabledNotifier.new);

class PushNotificationEnabledNotifier extends Notifier<bool> {
  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs?.getBool('push_notifications_enabled') ?? true;
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (prefs != null) {
      await prefs.setBool('push_notifications_enabled', enabled);
    }
    state = enabled;
    
    // If enabled, initialize push notifications and register the current token
    if (enabled) {
      final manager = ref.read(pushNotificationManagerProvider);
      await manager.initialize();
      await manager.registerCurrentToken();
    }
    
    if (!enabled) {
      final manager = ref.read(pushNotificationManagerProvider);
      await manager.unregisterPushToken();
    }
  }
}

/// Provider for PushNotificationService
final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService();
});

/// Provider for PushNotificationApi
final pushNotificationApiProvider = Provider<PushNotificationApi>((ref) {
  final dio = ref.watch(dioProvider);
  return PushNotificationApi(dio);
});

/// Provider for PushNotificationManager
final pushNotificationManagerProvider = Provider<PushNotificationManager>((ref) {
  final service = ref.watch(pushNotificationServiceProvider);
  final api = ref.watch(pushNotificationApiProvider);
  return PushNotificationManager(
    notificationService: service,
    api: api,
    ref: ref,
  );
});