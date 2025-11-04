import 'package:dartz/dartz.dart';
import 'dart:typed_data';
import '../../../../core/error/failures.dart';

abstract class FaceIdRepository {
  Future<Either<Failure, String>> registerFaceId({
    required Uint8List embedding,
    required String userId,
  });

  Future<Either<Failure, String>> updateFaceId({
    required Uint8List embedding,
    required String userId,
  });

  Future<Either<Failure, String>> verifyFaceId({
    required Uint8List embedding,
    required String userId,
    required String requestId,
    double? threshold,
  });
}
