import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../models/paginated_notifications.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsParams {
  final int limit;
  final int offset;
  final bool unreadOnly;

  const GetNotificationsParams({
    this.limit = 20,
    this.offset = 0,
    this.unreadOnly = false,
  });
}

class GetNotificationsUseCase
    implements UseCase<PaginatedNotifications, GetNotificationsParams> {
  final NotificationRepository repository;

  const GetNotificationsUseCase(this.repository);

  @override
  Future<Either<Failure, PaginatedNotifications>> call(
    GetNotificationsParams params,
  ) async {
    return await repository.getNotifications(
      limit: params.limit,
      offset: params.offset,
      unreadOnly: params.unreadOnly,
    );
  }
}
