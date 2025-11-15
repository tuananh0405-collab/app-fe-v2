import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/leave_balance_entity.dart';
import '../../domain/entities/leave_entity.dart';
import '../../domain/repositories/leave_repository.dart';
import '../datasources/leave_remote_datasource.dart';

class LeaveRepositoryImpl implements LeaveRepository {
  final LeaveRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  LeaveRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
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
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.createLeaveRequest(
          employeeId: employeeId,
          employeeCode: employeeCode,
          departmentId: departmentId,
          leaveTypeId: leaveTypeId,
          startDate: startDate,
          endDate: endDate,
          isHalfDayStart: isHalfDayStart,
          isHalfDayEnd: isHalfDayEnd,
          reason: reason,
          supportingDocumentUrl: supportingDocumentUrl,
          metadata: metadata,
        );
        return Right(result);
      } on UnauthorizedException catch (e) {
        return Left(AuthFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Unexpected error: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<LeaveEntity>>> getLeaveRecords() async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getLeaveRecords();
        return Right(result);
      } on UnauthorizedException catch (e) {
        return Left(AuthFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Unexpected error: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, LeaveEntity>> getLeaveRecordById({
    required int leaveId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getLeaveRecordById(
          leaveId: leaveId,
        );
        return Right(result);
      } on UnauthorizedException catch (e) {
        return Left(AuthFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Unexpected error: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
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
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.updateLeaveRequest(
          leaveId: leaveId,
          employeeId: employeeId,
          employeeCode: employeeCode,
          departmentId: departmentId,
          leaveTypeId: leaveTypeId,
          startDate: startDate,
          endDate: endDate,
          isHalfDayStart: isHalfDayStart,
          isHalfDayEnd: isHalfDayEnd,
          reason: reason,
          supportingDocumentUrl: supportingDocumentUrl,
          metadata: metadata,
        );
        return Right(result);
      } on UnauthorizedException catch (e) {
        return Left(AuthFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Unexpected error: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<LeaveBalanceEntity>>> getLeaveBalance({
    required int employeeId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getLeaveBalance(
          employeeId: employeeId,
        );
        return Right(result);
      } on UnauthorizedException catch (e) {
        return Left(AuthFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Unexpected error: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, LeaveEntity>> cancelLeaveRequest({
    required int leaveId,
    required String cancellationReason,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.cancelLeaveRequest(
          leaveId: leaveId,
          cancellationReason: cancellationReason,
        );
        return Right(result);
      } on UnauthorizedException catch (e) {
        return Left(AuthFailure(e.message));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      } catch (e) {
        return Left(ServerFailure('Unexpected error: ${e.toString()}'));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}
