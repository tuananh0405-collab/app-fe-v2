import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/leave_entity.dart';
import '../repositories/leave_repository.dart';

class CreateLeaveRequestParams {
  final int employeeId;
  final String employeeCode;
  final int departmentId;
  final int leaveTypeId;
  final DateTime startDate;
  final DateTime endDate;
  final bool isHalfDayStart;
  final bool isHalfDayEnd;
  final String reason;
  final String? supportingDocumentUrl;
  final Map<String, dynamic>? metadata;

  const CreateLeaveRequestParams({
    required this.employeeId,
    required this.employeeCode,
    required this.departmentId,
    required this.leaveTypeId,
    required this.startDate,
    required this.endDate,
    required this.isHalfDayStart,
    required this.isHalfDayEnd,
    required this.reason,
    this.supportingDocumentUrl,
    this.metadata,
  });
}

class CreateLeaveRequestUseCase
    implements UseCase<LeaveEntity, CreateLeaveRequestParams> {
  final LeaveRepository repository;

  CreateLeaveRequestUseCase(this.repository);

  @override
  Future<Either<Failure, LeaveEntity>> call(
      CreateLeaveRequestParams params) async {
    return await repository.createLeaveRequest(
      employeeId: params.employeeId,
      employeeCode: params.employeeCode,
      departmentId: params.departmentId,
      leaveTypeId: params.leaveTypeId,
      startDate: params.startDate,
      endDate: params.endDate,
      isHalfDayStart: params.isHalfDayStart,
      isHalfDayEnd: params.isHalfDayEnd,
      reason: params.reason,
      supportingDocumentUrl: params.supportingDocumentUrl,
      metadata: params.metadata,
    );
  }
}
