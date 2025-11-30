import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/leave_entity.dart';
import '../repositories/leave_repository.dart';

class GetLeaveRecordsUseCase
    implements UseCase<List<LeaveEntity>, GetLeaveRecordsParams> {
  final LeaveRepository repository;

  GetLeaveRecordsUseCase(this.repository);

  @override
  Future<Either<Failure, List<LeaveEntity>>> call(
    GetLeaveRecordsParams params,
  ) async {
    return await repository.getLeaveRecords(
      employeeId: params.employeeId,
      status: params.status,
      leaveTypeId: params.leaveTypeId,
      startDate: params.startDate,
      endDate: params.endDate,
      departmentId: params.departmentId,
    );
  }
}

class GetLeaveRecordsParams {
  final int? employeeId;
  final String? status;
  final int? leaveTypeId;
  final String? startDate;
  final String? endDate;
  final int? departmentId;

  const GetLeaveRecordsParams({
    this.employeeId,
    this.status,
    this.leaveTypeId,
    this.startDate,
    this.endDate,
    this.departmentId,
  });
}
