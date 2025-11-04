import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';
import '../../domain/usecases/register_faceid_usecase.dart';
import '../../domain/usecases/update_faceid_usecase.dart';
import '../providers/faceid_providers.dart';
import '../state/faceid_state.dart';

class FaceIdController extends Notifier<FaceIdState> {
  late final RegisterFaceIdUseCase _registerFaceIdUseCase;
  late final UpdateFaceIdUseCase _updateFaceIdUseCase;

  @override
  FaceIdState build() {
    _registerFaceIdUseCase = ref.read(registerFaceIdUseCaseProvider);
    _updateFaceIdUseCase = ref.read(updateFaceIdUseCaseProvider);
    return FaceIdState.initial();
  }

  Future<void> registerFaceId({
    required Uint8List embedding,
    required String userId,
  }) async {
    state = FaceIdState.loading();

    final result = await _registerFaceIdUseCase(
      RegisterFaceIdParams(
        embedding: embedding,
        userId: userId,
      ),
    );

    result.fold(
      (failure) => state = FaceIdState.error(failure.message),
      (message) => state = FaceIdState.success(message),
    );
  }

  Future<void> updateFaceId({
    required Uint8List embedding,
    required String userId,
  }) async {
    state = FaceIdState.loading();

    final result = await _updateFaceIdUseCase(
      UpdateFaceIdParams(
        embedding: embedding,
        userId: userId,
      ),
    );

    result.fold(
      (failure) => state = FaceIdState.error(failure.message),
      (message) => state = FaceIdState.success(message),
    );
  }

  void reset() {
    state = FaceIdState.initial();
  }
}
