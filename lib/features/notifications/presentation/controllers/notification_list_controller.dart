import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_as_read_usecase.dart';
import '../../domain/usecases/mark_all_as_read_usecase.dart';
import '../../providers/notification_providers.dart';
import '../state/notification_list_state.dart';

class NotificationListController extends Notifier<NotificationListState> {
  late final GetNotificationsUseCase _getNotificationsUseCase;
  late final MarkAsReadUseCase _markAsReadUseCase;
  late final MarkAllAsReadUseCase _markAllAsReadUseCase;

  @override
  NotificationListState build() {
    _getNotificationsUseCase = ref.read(getNotificationsUseCaseProvider);
    _markAsReadUseCase = ref.read(markAsReadUseCaseProvider);
    _markAllAsReadUseCase = ref.read(markAllAsReadUseCaseProvider);
    return const NotificationListState();
  }

  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      state = const NotificationListState(status: NotificationListStatus.loading);
    } else if (state.status == NotificationListStatus.initial) {
      state = state.copyWith(status: NotificationListStatus.loading);
    }

    final result = await _getNotificationsUseCase(
      const GetNotificationsParams(limit: 20, offset: 0),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: NotificationListStatus.error,
          errorMessage: failure.message,
        );
      },
      (paginatedData) {
        state = state.copyWith(
          status: NotificationListStatus.loaded,
          notifications: paginatedData.notifications,
          total: paginatedData.total,
          offset: paginatedData.offset,
          limit: paginatedData.limit,
          hasMore: paginatedData.hasMore,
          unreadCount: paginatedData.unreadCount,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.status == NotificationListStatus.loadingMore) {
      return;
    }

    state = state.copyWith(status: NotificationListStatus.loadingMore);

    final nextOffset = state.offset + state.limit;
    final result = await _getNotificationsUseCase(
      GetNotificationsParams(limit: state.limit, offset: nextOffset),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: NotificationListStatus.loaded,
          errorMessage: failure.message,
        );
      },
      (paginatedData) {
        final updatedNotifications = [
          ...state.notifications,
          ...paginatedData.notifications,
        ];
        state = state.copyWith(
          status: NotificationListStatus.loaded,
          notifications: updatedNotifications,
          total: paginatedData.total,
          offset: paginatedData.offset,
          hasMore: paginatedData.hasMore,
          unreadCount: paginatedData.unreadCount,
        );
      },
    );
  }

  Future<void> markAsRead(int notificationId) async {
    final result = await _markAsReadUseCase(
      MarkAsReadParams(notificationId: notificationId),
    );

    result.fold(
      (failure) {
        // Handle error silently or show snackbar
        state = state.copyWith(errorMessage: failure.message);
      },
      (_) {
        // Update local state
        final updatedNotifications = state.notifications.map((notification) {
          if (notification.id == notificationId) {
            return notification.copyWith(isRead: true, readAt: DateTime.now());
          }
          return notification;
        }).toList();

        final newUnreadCount = state.unreadCount > 0 ? state.unreadCount - 1 : 0;

        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: newUnreadCount,
        );
      },
    );
  }

  Future<void> markAllAsRead() async {
    final result = await _markAllAsReadUseCase(const NoParams());

    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (_) {
        // Update local state
        final updatedNotifications = state.notifications
            .map((notification) => notification.copyWith(isRead: true, readAt: DateTime.now()))
            .toList();

        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: 0,
        );
      },
    );
  }
}
