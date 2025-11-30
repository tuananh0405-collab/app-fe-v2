import '../entities/attendance_entity.dart';
import '../repositories/attendance_repository.dart';

class GetMyAttendanceUseCase {
  final AttendanceRepository repository;

  GetMyAttendanceUseCase(this.repository);

  Future<AttendanceResponse> call({
    required String referenceDate,
    required String period,
    String? status,
    int page = 1,
    int limit = 20,
  }) {
    return repository.getMyAttendance(
      referenceDate: referenceDate,
      period: period,
      status: status,
      page: page,
      limit: limit,
    );
  }
}
