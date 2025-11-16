import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../models/paginated_notifications.dart';

abstract class NotificationRepository {
  Future<Either<Failure, PaginatedNotifications>> getNotifications({
    required int limit,
    required int offset,
    bool unreadOnly = false,
    String channelFilter = 'IN_APP',
  });
  
  Future<Either<Failure, void>> markAsRead(int notificationId);
  
  Future<Either<Failure, void>> markAllAsRead();
}
