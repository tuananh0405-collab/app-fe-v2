import 'package:state_notifier/state_notifier.dart';
import '../../domain/usecases/get_my_attendance_usecase.dart';
import '../state/attendance_state.dart';

class AttendanceController extends StateNotifier<AttendanceState> {
  final GetMyAttendanceUseCase getMyAttendanceUseCase;

  AttendanceController({required this.getMyAttendanceUseCase})
      : super(AttendanceState(
          startDate: _getDefaultStartDate(),
          endDate: _getDefaultEndDate(),
        ));

  static String _getDefaultStartDate() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    return firstDayOfMonth.toIso8601String().split('T')[0];
  }

  static String _getDefaultEndDate() {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    return lastDayOfMonth.toIso8601String().split('T')[0];
  }

  Future<void> loadAttendance({
    String? startDate,
    String? endDate,
    String? status,
  }) async {
    state = state.copyWith(
      status: AttendanceStatus.loading,
      startDate: startDate ?? state.startDate,
      endDate: endDate ?? state.endDate,
      selectedStatus: status,
    );

    try {
      final result = await getMyAttendanceUseCase(
        startDate: state.startDate,
        endDate: state.endDate,
        status: state.selectedStatus,
      );
      state = state.copyWith(
        status: AttendanceStatus.success,
        data: result,
      );
    } catch (e) {
      state = state.copyWith(
        status: AttendanceStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }

  void updateDateRange(DateTime start, DateTime end) {
    loadAttendance(
      startDate: start.toIso8601String().split('T')[0],
      endDate: end.toIso8601String().split('T')[0],
    );
  }

  void updateStatus(String? status) {
    loadAttendance(status: status);
  }

  void clearStatusFilter() {
    state = state.copyWith(
      status: AttendanceStatus.loading,
      clearSelectedStatus: true,
    );
    
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    try {
      final result = await getMyAttendanceUseCase(
        startDate: state.startDate,
        endDate: state.endDate,
        status: state.selectedStatus,
      );
      state = state.copyWith(
        status: AttendanceStatus.success,
        data: result,
      );
    } catch (e) {
      state = state.copyWith(
        status: AttendanceStatus.failure,
        errorMessage: e.toString(),
      );
    }
  }
}
