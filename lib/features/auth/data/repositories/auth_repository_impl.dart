import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/login_response_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, LoginResponseEntity>> login({
    required String email,
    required String password,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.login(
          email: email,
          password: password,
        );
        return Right(result);
      } on UnauthorizedException catch (e) {
        return Left(AuthFailure(e.message));
      } on TemporaryPasswordException catch (e) {
        return Left(TemporaryPasswordFailure(e.message));
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
  Future<Either<Failure, LoginResponseEntity>> loginWithDeviceInfo(
    LoginRequest loginRequest,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.loginWithDeviceInfo(loginRequest);
        return Right(result);
      } on UnauthorizedException catch (e) {
        return Left(AuthFailure(e.message));
      } on TemporaryPasswordException catch (e) {
        return Left(TemporaryPasswordFailure(e.message));
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
  Future<Either<Failure, void>> changeTemporaryPassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.changeTemporaryPassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
          confirmPassword: confirmPassword,
        );
        return const Right(null);
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
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.changePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
        return const Right(null);
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
