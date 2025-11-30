import '../../../../core/network/network_info.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_datasource.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AttendanceRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<AttendanceResponse> getMyAttendance({
    required String startDate,
    required String endDate,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      final model = await remoteDataSource.getMyAttendance(
        startDate: startDate,
        endDate: endDate,
        status: status,
        page: page,
        limit: limit,
      );
      return model.toEntity();
    } else {
      throw Exception('No internet connection');
    }
  }
}
