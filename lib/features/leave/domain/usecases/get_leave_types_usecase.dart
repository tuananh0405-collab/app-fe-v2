import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/leave_type_entity.dart';
import '../repositories/leave_repository.dart';

class GetLeaveTypesUseCase implements UseCase<List<LeaveTypeEntity>, NoParams> {
  final LeaveRepository repository;

  GetLeaveTypesUseCase(this.repository);

  @override
  Future<Either<Failure, List<LeaveTypeEntity>>> call(NoParams params) async {
    return await repository.getLeaveTypes();
  }
}
