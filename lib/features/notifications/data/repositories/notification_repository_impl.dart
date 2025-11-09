import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/models/paginated_notifications.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  NotificationRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, PaginatedNotifications>> getNotifications({
    required int limit,
    required int offset,
    bool unreadOnly = false,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getNotifications(
          limit: limit,
          offset: offset,
          unreadOnly: unreadOnly,
        );
        return Right(result);
      } on UnauthorizedException catch (e) {
        return Left(AuthFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(int notificationId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.markAsRead(notificationId);
        return const Right(null);
      } on UnauthorizedException catch (e) {
        return Left(AuthFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.markAllAsRead();
        return const Right(null);
      } on UnauthorizedException catch (e) {
        return Left(AuthFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}
