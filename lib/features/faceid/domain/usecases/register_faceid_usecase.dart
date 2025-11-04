import 'package:dartz/dartz.dart';
import 'dart:typed_data';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/faceid_repository.dart';

class RegisterFaceIdParams {
  final Uint8List embedding;
  final String userId;

  const RegisterFaceIdParams({
    required this.embedding,
    required this.userId,
  });
}

class RegisterFaceIdUseCase implements UseCase<String, RegisterFaceIdParams> {
  final FaceIdRepository repository;

  const RegisterFaceIdUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(RegisterFaceIdParams params) async {
    return await repository.registerFaceId(
      embedding: params.embedding,
      userId: params.userId,
    );
  }
}
