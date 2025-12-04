import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/employee_shift_entity.dart';
import '../repositories/work_schedule_repository.dart';

class GetEmployeeShiftsParams {
  final DateTime fromDate;
  final DateTime toDate;
  final int? employeeId;

  const GetEmployeeShiftsParams({
    required this.fromDate,
    required this.toDate,
    this.employeeId,
  });
}

class GetEmployeeShiftsUseCase
    implements UseCase<List<EmployeeShiftEntity>, GetEmployeeShiftsParams> {
  final WorkScheduleRepository repository;

  GetEmployeeShiftsUseCase(this.repository);

  @override
  Future<Either<Failure, List<EmployeeShiftEntity>>> call(
      GetEmployeeShiftsParams params) async {
    return await repository.getEmployeeShifts(
      fromDate: params.fromDate,
      toDate: params.toDate,
      employeeId: params.employeeId,
    );
  }
}

