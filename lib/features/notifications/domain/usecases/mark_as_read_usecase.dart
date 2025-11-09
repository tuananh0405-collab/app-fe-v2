import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

class MarkAsReadParams {
  final int notificationId;

  const MarkAsReadParams({required this.notificationId});
}

class MarkAsReadUseCase implements UseCase<void, MarkAsReadParams> {
  final NotificationRepository repository;

  const MarkAsReadUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(MarkAsReadParams params) async {
    return await repository.markAsRead(params.notificationId);
  }
}
