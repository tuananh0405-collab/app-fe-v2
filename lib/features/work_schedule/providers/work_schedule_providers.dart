import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/network_info.dart';
import '../data/datasources/work_schedule_remote_datasource.dart';
import '../data/repositories/work_schedule_repository_impl.dart';
import '../domain/repositories/work_schedule_repository.dart';
import '../domain/usecases/get_employee_shifts_usecase.dart';
import '../presentation/controllers/work_schedule_controller.dart';
import '../presentation/state/work_schedule_state.dart';

// Data Source Provider
final workScheduleRemoteDataSourceProvider =
    Provider<WorkScheduleRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return WorkScheduleRemoteDataSourceImpl(dio: dio);
});

// Repository Provider
final workScheduleRepositoryProvider =
    Provider<WorkScheduleRepository>((ref) {
  return WorkScheduleRepositoryImpl(
    remoteDataSource: ref.read(workScheduleRemoteDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

// Use Case Provider
final getEmployeeShiftsUseCaseProvider =
    Provider<GetEmployeeShiftsUseCase>((ref) {
  return GetEmployeeShiftsUseCase(ref.read(workScheduleRepositoryProvider));
});

// Work Schedule Controller Provider
final workScheduleControllerProvider =
    NotifierProvider<WorkScheduleController, WorkScheduleState>(
  () => WorkScheduleController(),
);

