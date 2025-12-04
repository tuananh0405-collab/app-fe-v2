import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/overtime_entity.dart';
import '../../domain/repositories/overtime_repository.dart';
import '../datasources/overtime_remote_datasource.dart';

class OvertimeRepositoryImpl implements OvertimeRepository {
  final OvertimeRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  OvertimeRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, OvertimeEntity>> createOvertimeRequest({
    required DateTime overtimeDate,
    required DateTime startTime,
    required DateTime endTime,
    required double estimatedHours,
    required String reason,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final overtime = await remoteDataSource.createOvertimeRequest(
          overtimeDate: overtimeDate,
          startTime: startTime,
          endTime: endTime,
          estimatedHours: estimatedHours,
          reason: reason,
        );
        return Right(overtime);
      } on UnauthorizedException catch (e) {
        return Left(AuthFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<OvertimeEntity>>> getMyOvertimeRequests({
    int limit = 20,
    int offset = 0,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final overtimeRequests = await remoteDataSource.getMyOvertimeRequests(
          limit: limit,
          offset: offset,
        );
        return Right(overtimeRequests);
      } on UnauthorizedException catch (e) {
        return Left(AuthFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, OvertimeEntity>> getOvertimeRequestById({
    required int overtimeId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final overtime = await remoteDataSource.getOvertimeRequestById(
          overtimeId: overtimeId,
        );
        return Right(overtime);
      } on UnauthorizedException catch (e) {
        return Left(AuthFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> updateOvertimeRequest({
    required int overtimeId,
    required int shiftId,
    required DateTime overtimeDate,
    required DateTime startTime,
    required DateTime endTime,
    required double estimatedHours,
    required String reason,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateOvertimeRequest(
          overtimeId: overtimeId,
          shiftId: shiftId,
          overtimeDate: overtimeDate,
          startTime: startTime,
          endTime: endTime,
          estimatedHours: estimatedHours,
          reason: reason,
        );
        return const Right(null); // Hoặc Right(unit) nếu dùng dartz
      } on UnauthorizedException catch (e) {
        return Left(AuthFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelOvertimeRequest({
    required int overtimeId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.cancelOvertimeRequest(overtimeId: overtimeId);
        return const Right(null);
      } on UnauthorizedException catch (e) {
        return Left(AuthFailure(e.message));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}
