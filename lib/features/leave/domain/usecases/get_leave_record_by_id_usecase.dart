import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/leave_entity.dart';
import '../repositories/leave_repository.dart';

class GetLeaveRecordByIdUseCase implements UseCase<LeaveEntity, GetLeaveRecordByIdParams> {
  final LeaveRepository repository;

  GetLeaveRecordByIdUseCase(this.repository);

  @override
  Future<Either<Failure, LeaveEntity>> call(GetLeaveRecordByIdParams params) async {
    return await repository.getLeaveRecordById(
      leaveId: params.leaveId,
    );
  }
}

class GetLeaveRecordByIdParams {
  final int leaveId;

  GetLeaveRecordByIdParams({required this.leaveId});
}
