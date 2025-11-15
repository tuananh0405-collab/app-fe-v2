import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/leave_balance_entity.dart';
import '../repositories/leave_repository.dart';

class GetLeaveBalanceParams {
  final int employeeId;

  const GetLeaveBalanceParams({required this.employeeId});
}

class GetLeaveBalanceUseCase
    implements UseCase<List<LeaveBalanceEntity>, GetLeaveBalanceParams> {
  final LeaveRepository repository;

  GetLeaveBalanceUseCase(this.repository);

  @override
  Future<Either<Failure, List<LeaveBalanceEntity>>> call(
      GetLeaveBalanceParams params) async {
    return await repository.getLeaveBalance(employeeId: params.employeeId);
  }
}
