import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/network_info.dart';
import '../data/datasources/attendance_remote_datasource.dart';
import '../data/repositories/attendance_repository_impl.dart';
import '../domain/repositories/attendance_repository.dart';
import '../domain/usecases/get_my_attendance_usecase.dart';
import '../presentation/controllers/attendance_controller.dart';
import '../presentation/state/attendance_state.dart';

// Data Source
final attendanceRemoteDataSourceProvider =
    Provider<AttendanceRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return AttendanceRemoteDataSourceImpl(dio: dio);
});

// Repository
final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepositoryImpl(
    remoteDataSource: ref.read(attendanceRemoteDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

// Use Case
final getMyAttendanceUseCaseProvider = Provider<GetMyAttendanceUseCase>((ref) {
  return GetMyAttendanceUseCase(ref.read(attendanceRepositoryProvider));
});

// Controller
final attendanceControllerProvider =
    StateNotifierProvider<AttendanceController, AttendanceState>((ref) {
  return AttendanceController(
    getMyAttendanceUseCase: ref.read(getMyAttendanceUseCaseProvider),
  );
});
