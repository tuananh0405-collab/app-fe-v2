import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/notification_preference_remote_datasource.dart';
import '../data/repositories/notification_preference_repository_impl.dart';
import '../domain/repositories/notification_preference_repository.dart';
import '../domain/usecases/get_notification_preferences_usecase.dart';
import '../domain/usecases/update_notification_preference_usecase.dart';
import '../presentation/controllers/notification_preference_controller.dart';
import '../presentation/state/notification_preference_state.dart';
import '../../../core/network/dio_client.dart';

/// Provider for NotificationPreferenceRemoteDataSource
final notificationPreferenceRemoteDataSourceProvider =
    Provider<NotificationPreferenceRemoteDataSource>((ref) {
  return NotificationPreferenceRemoteDataSourceImpl(dio: ref.watch(dioProvider));
});

/// Provider for NotificationPreferenceRepository
final notificationPreferenceRepositoryProvider =
    Provider<NotificationPreferenceRepository>((ref) {
  return NotificationPreferenceRepositoryImpl(
    remoteDataSource: ref.watch(notificationPreferenceRemoteDataSourceProvider),
  );
});

/// Provider for GetNotificationPreferencesUseCase
final getNotificationPreferencesUseCaseProvider =
    Provider<GetNotificationPreferencesUseCase>((ref) {
  return GetNotificationPreferencesUseCase(
    ref.watch(notificationPreferenceRepositoryProvider),
  );
});

/// Provider for UpdateNotificationPreferenceUseCase
final updateNotificationPreferenceUseCaseProvider =
    Provider<UpdateNotificationPreferenceUseCase>((ref) {
  return UpdateNotificationPreferenceUseCase(
    ref.watch(notificationPreferenceRepositoryProvider),
  );
});

/// Provider for NotificationPreferenceController
final notificationPreferenceControllerProvider =
    NotifierProvider<NotificationPreferenceController, NotificationPreferenceState>(() {
  return NotificationPreferenceController();
});
