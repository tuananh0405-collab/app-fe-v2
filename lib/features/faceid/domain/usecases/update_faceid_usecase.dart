import 'package:dartz/dartz.dart';
import 'dart:typed_data';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/faceid_repository.dart';

class UpdateFaceIdParams {
  final Uint8List embedding;
  final String userId;

  const UpdateFaceIdParams({
    required this.embedding,
    required this.userId,
  });
}

class UpdateFaceIdUseCase implements UseCase<String, UpdateFaceIdParams> {
  final FaceIdRepository repository;

  const UpdateFaceIdUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(UpdateFaceIdParams params) async {
    return await repository.updateFaceId(
      embedding: params.embedding,
      userId: params.userId,
    );
  }
}
