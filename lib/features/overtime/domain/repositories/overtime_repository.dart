import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/overtime_entity.dart';

abstract class OvertimeRepository {
  Future<Either<Failure, OvertimeEntity>> createOvertimeRequest({
    required int shiftId,
    required DateTime overtimeDate,
    required DateTime startTime,
    required DateTime endTime,
    required double estimatedHours,
    required String reason,
  });

  Future<Either<Failure, List<OvertimeEntity>>> getMyOvertimeRequests({
    int limit = 20,
    int offset = 0,
  });

  Future<Either<Failure, OvertimeEntity>> getOvertimeRequestById({
    required int overtimeId,
  });

  Future<Either<Failure, OvertimeEntity>> updateOvertimeRequest({
    required int overtimeId,
    required int shiftId,
    required DateTime overtimeDate,
    required DateTime startTime,
    required DateTime endTime,
    required double estimatedHours,
    required String reason,
  });
}
