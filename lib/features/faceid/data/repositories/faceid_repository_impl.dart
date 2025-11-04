import 'package:dartz/dartz.dart';
import 'dart:typed_data';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/faceid_repository.dart';
import '../datasources/faceid_remote_datasource.dart';

class FaceIdRepositoryImpl implements FaceIdRepository {
  final FaceIdRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  FaceIdRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, String>> registerFaceId({
    required Uint8List embedding,
    required String userId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.registerFaceId(
          embedding: embedding,
          userId: userId,
        );
        
        if (result.success) {
          return Right(result.message);
        } else {
          return Left(ServerFailure(result.message));
        }
      } on UnauthorizedException catch (e) {
        return Left(AuthFailure(e.message));
      } on ServerException catch (e) {
        // Check if we should retry with update
        if (e.message.contains('already registered')) {
          return await updateFaceId(embedding: embedding, userId: userId);
        }
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, String>> updateFaceId({
    required Uint8List embedding,
    required String userId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.updateFaceId(
          embedding: embedding,
          userId: userId,
        );
        
        if (result.success) {
          return Right(result.message);
        } else {
          return Left(ServerFailure(result.message));
        }
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
  Future<Either<Failure, String>> verifyFaceId({
    required Uint8List embedding,
    required String userId,
    required String requestId,
    double? threshold,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.verifyFaceId(
          embedding: embedding,
          userId: userId,
          requestId: requestId,
          threshold: threshold,
        );
        
        if (result.success) {
          return Right(result.message);
        } else {
          return Left(ServerFailure(result.message));
        }
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
