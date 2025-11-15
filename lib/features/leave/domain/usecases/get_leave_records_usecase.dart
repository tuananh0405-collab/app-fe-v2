import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/leave_entity.dart';
import '../repositories/leave_repository.dart';

class GetLeaveRecordsUseCase implements UseCase<List<LeaveEntity>, NoParams> {
  final LeaveRepository repository;

  GetLeaveRecordsUseCase(this.repository);

  @override
  Future<Either<Failure, List<LeaveEntity>>> call(NoParams params) async {
    return await repository.getLeaveRecords();
  }
}
