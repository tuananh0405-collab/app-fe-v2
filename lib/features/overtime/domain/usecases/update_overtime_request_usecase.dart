import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/overtime_entity.dart';
import '../repositories/overtime_repository.dart';

class UpdateOvertimeRequestUseCase
    implements UseCase<OvertimeEntity, UpdateOvertimeRequestParams> {
  final OvertimeRepository repository;

  UpdateOvertimeRequestUseCase(this.repository);

  @override
  Future<Either<Failure, OvertimeEntity>> call(
      UpdateOvertimeRequestParams params) async {
    return await repository.updateOvertimeRequest(
      overtimeId: params.overtimeId,
      shiftId: params.shiftId,
      overtimeDate: params.overtimeDate,
      startTime: params.startTime,
      endTime: params.endTime,
      estimatedHours: params.estimatedHours,
      reason: params.reason,
    );
  }
}

class UpdateOvertimeRequestParams {
  final int overtimeId;
  final int shiftId;
  final DateTime overtimeDate;
  final DateTime startTime;
  final DateTime endTime;
  final double estimatedHours;
  final String reason;

  UpdateOvertimeRequestParams({
    required this.overtimeId,
    required this.shiftId,
    required this.overtimeDate,
    required this.startTime,
    required this.endTime,
    required this.estimatedHours,
    required this.reason,
  });
}
