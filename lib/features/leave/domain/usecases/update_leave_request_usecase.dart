import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/leave_entity.dart';
import '../repositories/leave_repository.dart';

class UpdateLeaveRequestParams {
  final int leaveId;
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

  const UpdateLeaveRequestParams({
    required this.leaveId,
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

class UpdateLeaveRequestUseCase
    implements UseCase<LeaveEntity, UpdateLeaveRequestParams> {
  final LeaveRepository repository;

  UpdateLeaveRequestUseCase(this.repository);

  @override
  Future<Either<Failure, LeaveEntity>> call(
      UpdateLeaveRequestParams params) async {
    return await repository.updateLeaveRequest(
      leaveId: params.leaveId,
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
