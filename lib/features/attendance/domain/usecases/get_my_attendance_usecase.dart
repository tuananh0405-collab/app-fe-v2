import '../entities/attendance_entity.dart';
import '../repositories/attendance_repository.dart';

class GetMyAttendanceUseCase {
  final AttendanceRepository repository;

  GetMyAttendanceUseCase(this.repository);

  Future<AttendanceResponse> call({
    required String startDate,
    required String endDate,
    String? status,
    int page = 1,
    int limit = 20,
  }) {
    return repository.getMyAttendance(
      startDate: startDate,
      endDate: endDate,
      status: status,
      page: page,
      limit: limit,
    );
  }
}
