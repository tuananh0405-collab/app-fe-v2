import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/overtime_entity.dart';
import '../repositories/overtime_repository.dart';

class GetOvertimeRequestByIdUseCase
    implements UseCase<OvertimeEntity, GetOvertimeRequestByIdParams> {
  final OvertimeRepository repository;

  GetOvertimeRequestByIdUseCase(this.repository);

  @override
  Future<Either<Failure, OvertimeEntity>> call(
      GetOvertimeRequestByIdParams params) async {
    return await repository.getOvertimeRequestById(
      overtimeId: params.overtimeId,
    );
  }
}

class GetOvertimeRequestByIdParams {
  final int overtimeId;

  GetOvertimeRequestByIdParams({required this.overtimeId});
}
