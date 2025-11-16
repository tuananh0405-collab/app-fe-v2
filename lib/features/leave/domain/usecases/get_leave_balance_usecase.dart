import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/leave_balance_entity.dart';
import '../repositories/leave_repository.dart';

class GetLeaveBalanceUseCase
    implements UseCase<List<LeaveBalanceEntity>, NoParams> {
  final LeaveRepository repository;

  GetLeaveBalanceUseCase(this.repository);

  @override
  Future<Either<Failure, List<LeaveBalanceEntity>>> call(
      NoParams params) async {
    return await repository.getLeaveBalance();
  }
}
