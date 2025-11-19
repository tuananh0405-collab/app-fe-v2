import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/employee_shift_entity.dart';

abstract class WorkScheduleRepository {
  Future<Either<Failure, List<EmployeeShiftEntity>>> getEmployeeShifts({
    required DateTime fromDate,
    required DateTime toDate,
  });
}

