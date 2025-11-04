import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/network_info.dart';
import '../../data/datasources/faceid_remote_datasource.dart';
import '../../data/repositories/faceid_repository_impl.dart';
import '../../domain/repositories/faceid_repository.dart';
import '../../domain/usecases/register_faceid_usecase.dart';
import '../../domain/usecases/update_faceid_usecase.dart';
import '../controllers/faceid_controller.dart';
import '../state/faceid_state.dart';

// Data source provider
final faceIdRemoteDataSourceProvider = Provider<FaceIdRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return FaceIdRemoteDataSourceImpl(dio: dio);
});

// Repository provider
final faceIdRepositoryProvider = Provider<FaceIdRepository>((ref) {
  return FaceIdRepositoryImpl(
    remoteDataSource: ref.read(faceIdRemoteDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

// Use case providers
final registerFaceIdUseCaseProvider = Provider<RegisterFaceIdUseCase>((ref) {
  return RegisterFaceIdUseCase(ref.read(faceIdRepositoryProvider));
});

final updateFaceIdUseCaseProvider = Provider<UpdateFaceIdUseCase>((ref) {
  return UpdateFaceIdUseCase(ref.read(faceIdRepositoryProvider));
});

// Controller provider
final faceIdControllerProvider =
    NotifierProvider<FaceIdController, FaceIdState>(() {
  return FaceIdController();
});
