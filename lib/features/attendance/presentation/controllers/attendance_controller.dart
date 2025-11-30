import 'package:state_notifier/state_notifier.dart';
import '../../domain/usecases/get_my_attendance_usecase.dart';
import '../state/attendance_state.dart';

class AttendanceController extends StateNotifier<AttendanceState> {
  final GetMyAttendanceUseCase getMyAttendanceUseCase;

  AttendanceController({required this.getMyAttendanceUseCase})
      : super(AttendanceState(
          referenceDate: DateTime.now().toIso8601String().split('T')[0],
        ));

  Future<void> loadAttendance({
    String? period,
    String? referenceDate,
    String? status,
  }) async {
    state = state.copyWith(
      status: AttendanceStatus.loading,
      selectedPeriod: period ?? state.selectedPeriod,
      referenceDate: referenceDate ?? state.referenceDate,
    );

    try {
      final result = await getMyAttendanceUseCase(
        referenceDate: state.referenceDate,
        period: state.selectedPeriod.toLowerCase(),
        status: status,
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

  void updatePeriod(String period) {
    loadAttendance(period: period);
  }

  void updateDate(DateTime date) {
    loadAttendance(referenceDate: date.toIso8601String().split('T')[0]);
  }
}
