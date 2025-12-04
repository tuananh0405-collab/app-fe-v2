import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/overtime_entity.dart';
import '../repositories/overtime_repository.dart';

class CreateOvertimeRequestUseCase
    implements UseCase<OvertimeEntity, CreateOvertimeRequestParams> {
  final OvertimeRepository repository;

  CreateOvertimeRequestUseCase(this.repository);

  @override
  Future<Either<Failure, OvertimeEntity>> call(
      CreateOvertimeRequestParams params) async {
    return await repository.createOvertimeRequest(
      // shiftId: params.shiftId,
      overtimeDate: params.overtimeDate,
      startTime: params.startTime,
      endTime: params.endTime,
      estimatedHours: params.estimatedHours,
      reason: params.reason,
    );
  }
}

class CreateOvertimeRequestParams {
  // final int shiftId;
  final DateTime overtimeDate;
  final DateTime startTime;
  final DateTime endTime;
  final double estimatedHours;
  final String reason;

  CreateOvertimeRequestParams({
    // required this.shiftId,
    required this.overtimeDate,
    required this.startTime,
    required this.endTime,
    required this.estimatedHours,
    required this.reason,
  });
}
