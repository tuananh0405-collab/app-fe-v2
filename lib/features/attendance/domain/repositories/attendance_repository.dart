import '../entities/attendance_entity.dart';

abstract class AttendanceRepository {
  Future<AttendanceResponse> getMyAttendance({
    required String startDate,
    required String endDate,
    String? status,
    int page = 1,
    int limit = 20,
  });
}
