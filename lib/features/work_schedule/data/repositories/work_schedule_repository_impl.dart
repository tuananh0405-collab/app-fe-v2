import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/employee_shift_entity.dart';
import '../../domain/repositories/work_schedule_repository.dart';
import '../datasources/work_schedule_remote_datasource.dart';

class WorkScheduleRepositoryImpl implements WorkScheduleRepository {
  final WorkScheduleRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  WorkScheduleRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<EmployeeShiftEntity>>> getEmployeeShifts({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getEmployeeShifts(
          fromDate: fromDate,
          toDate: toDate,
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

