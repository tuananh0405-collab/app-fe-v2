import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/network_info.dart';
import '../data/datasources/overtime_remote_datasource.dart';
import '../data/repositories/overtime_repository_impl.dart';
import '../domain/repositories/overtime_repository.dart';
import '../domain/usecases/cancel_overtime_request_usecase.dart';
import '../domain/usecases/create_overtime_request_usecase.dart';
import '../domain/usecases/get_my_overtime_requests_usecase.dart';
import '../domain/usecases/get_overtime_request_by_id_usecase.dart';
import '../domain/usecases/update_overtime_request_usecase.dart';
import '../presentation/controllers/overtime_controller.dart';
import '../presentation/state/overtime_state.dart';

// Data Source Provider
final overtimeRemoteDataSourceProvider =
    Provider<OvertimeRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return OvertimeRemoteDataSourceImpl(dio: dio);
});

// Repository Provider
final overtimeRepositoryProvider = Provider<OvertimeRepository>((ref) {
  return OvertimeRepositoryImpl(
    remoteDataSource: ref.read(overtimeRemoteDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

// Use Case Providers
final createOvertimeRequestUseCaseProvider =
    Provider<CreateOvertimeRequestUseCase>((ref) {
  return CreateOvertimeRequestUseCase(ref.read(overtimeRepositoryProvider));
});

final getMyOvertimeRequestsUseCaseProvider =
    Provider<GetMyOvertimeRequestsUseCase>((ref) {
  return GetMyOvertimeRequestsUseCase(ref.read(overtimeRepositoryProvider));
});

final getOvertimeRequestByIdUseCaseProvider =
    Provider<GetOvertimeRequestByIdUseCase>((ref) {
  return GetOvertimeRequestByIdUseCase(ref.read(overtimeRepositoryProvider));
});

final updateOvertimeRequestUseCaseProvider =
    Provider<UpdateOvertimeRequestUseCase>((ref) {
  return UpdateOvertimeRequestUseCase(ref.read(overtimeRepositoryProvider));
});

final cancelOvertimeRequestUseCaseProvider = Provider<CancelOvertimeRequestUseCase>((ref) {
  return CancelOvertimeRequestUseCase(ref.read(overtimeRepositoryProvider));
});

// Overtime Controller Provider
final overtimeControllerProvider =
    NotifierProvider<OvertimeController, OvertimeState>(
  () => OvertimeController(),
);
