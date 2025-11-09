import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/network_info.dart';
import '../data/datasources/notification_remote_datasource.dart';
import '../data/repositories/notification_repository_impl.dart';
import '../domain/repositories/notification_repository.dart';
import '../domain/usecases/get_notifications_usecase.dart';
import '../domain/usecases/mark_as_read_usecase.dart';
import '../domain/usecases/mark_all_as_read_usecase.dart';
import '../presentation/controllers/notification_list_controller.dart';
import '../presentation/state/notification_list_state.dart';

// Data Source Provider
final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return NotificationRemoteDataSourceImpl(dio: dio);
});

// Repository Provider
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(
    remoteDataSource: ref.read(notificationRemoteDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

// Use Case Providers
final getNotificationsUseCaseProvider = Provider<GetNotificationsUseCase>((ref) {
  return GetNotificationsUseCase(ref.read(notificationRepositoryProvider));
});

final markAsReadUseCaseProvider = Provider<MarkAsReadUseCase>((ref) {
  return MarkAsReadUseCase(ref.read(notificationRepositoryProvider));
});

final markAllAsReadUseCaseProvider = Provider<MarkAllAsReadUseCase>((ref) {
  return MarkAllAsReadUseCase(ref.read(notificationRepositoryProvider));
});

// Controller Provider
final notificationListControllerProvider =
    NotifierProvider<NotificationListController, NotificationListState>(() {
  return NotificationListController();
});
