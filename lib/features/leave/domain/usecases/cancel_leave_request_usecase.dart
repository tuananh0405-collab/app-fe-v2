import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/leave_entity.dart';
import '../repositories/leave_repository.dart';

class CancelLeaveRequestUseCase
    implements UseCase<LeaveEntity, CancelLeaveRequestParams> {
  final LeaveRepository repository;

  CancelLeaveRequestUseCase(this.repository);

  @override
  Future<Either<Failure, LeaveEntity>> call(
      CancelLeaveRequestParams params) async {
    return await repository.cancelLeaveRequest(
      leaveId: params.leaveId,
      cancellationReason: params.cancellationReason,
    );
  }
}

class CancelLeaveRequestParams {
  final int leaveId;
  final String cancellationReason;

  const CancelLeaveRequestParams({
    required this.leaveId,
    required this.cancellationReason,
  });
}
