import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/network_info.dart';
import '../data/datasources/leave_remote_datasource.dart';
import '../data/repositories/leave_repository_impl.dart';
import '../domain/repositories/leave_repository.dart';
import '../domain/usecases/create_leave_request_usecase.dart';
import '../domain/usecases/get_leave_balance_usecase.dart';
import '../domain/usecases/get_leave_record_by_id_usecase.dart';
import '../domain/usecases/get_leave_records_usecase.dart';
import '../domain/usecases/update_leave_request_usecase.dart';
import '../domain/usecases/cancel_leave_request_usecase.dart';
import '../presentation/controllers/leave_controller.dart';
import '../presentation/state/leave_state.dart';

// Data Source Provider
final leaveRemoteDataSourceProvider = Provider<LeaveRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return LeaveRemoteDataSourceImpl(dio: dio);
});

// Repository Provider
final leaveRepositoryProvider = Provider<LeaveRepository>((ref) {
  return LeaveRepositoryImpl(
    remoteDataSource: ref.read(leaveRemoteDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

// Use Case Providers
final createLeaveRequestUseCaseProvider =
    Provider<CreateLeaveRequestUseCase>((ref) {
  return CreateLeaveRequestUseCase(ref.read(leaveRepositoryProvider));
});

final getLeaveRecordsUseCaseProvider = Provider<GetLeaveRecordsUseCase>((ref) {
  return GetLeaveRecordsUseCase(ref.read(leaveRepositoryProvider));
});

final getLeaveBalanceUseCaseProvider = Provider<GetLeaveBalanceUseCase>((ref) {
  return GetLeaveBalanceUseCase(ref.read(leaveRepositoryProvider));
});

final updateLeaveRequestUseCaseProvider =
    Provider<UpdateLeaveRequestUseCase>((ref) {
  return UpdateLeaveRequestUseCase(ref.read(leaveRepositoryProvider));
});

final getLeaveRecordByIdUseCaseProvider =
    Provider<GetLeaveRecordByIdUseCase>((ref) {
  return GetLeaveRecordByIdUseCase(ref.read(leaveRepositoryProvider));
});

final cancelLeaveRequestUseCaseProvider =
    Provider<CancelLeaveRequestUseCase>((ref) {
  return CancelLeaveRequestUseCase(ref.read(leaveRepositoryProvider));
});

// Leave Controller Provider
final leaveControllerProvider = NotifierProvider<LeaveController, LeaveState>(
  () => LeaveController(),
);
