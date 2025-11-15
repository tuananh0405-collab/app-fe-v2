import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/leave_balance_entity.dart';
import '../entities/leave_entity.dart';

abstract class LeaveRepository {
  Future<Either<Failure, LeaveEntity>> createLeaveRequest({
    required int employeeId,
    required String employeeCode,
    required int departmentId,
    required int leaveTypeId,
    required DateTime startDate,
    required DateTime endDate,
    required bool isHalfDayStart,
    required bool isHalfDayEnd,
    required String reason,
    String? supportingDocumentUrl,
    Map<String, dynamic>? metadata,
  });

  Future<Either<Failure, List<LeaveEntity>>> getLeaveRecords();

  Future<Either<Failure, LeaveEntity>> getLeaveRecordById({
    required int leaveId,
  });

  Future<Either<Failure, LeaveEntity>> updateLeaveRequest({
    required int leaveId,
    required int employeeId,
    required String employeeCode,
    required int departmentId,
    required int leaveTypeId,
    required DateTime startDate,
    required DateTime endDate,
    required bool isHalfDayStart,
    required bool isHalfDayEnd,
    required String reason,
    String? supportingDocumentUrl,
    Map<String, dynamic>? metadata,
  });

  Future<Either<Failure, List<LeaveBalanceEntity>>> getLeaveBalance({
    required int employeeId,
  });

  Future<Either<Failure, LeaveEntity>> cancelLeaveRequest({
    required int leaveId,
    required String cancellationReason,
  });
}
