import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/employee_shift_entity.dart';
import '../../domain/usecases/get_employee_shifts_usecase.dart';
import '../../providers/work_schedule_providers.dart';
import '../../../auth/providers/auth_providers.dart';
import '../state/work_schedule_state.dart';

class WorkScheduleController extends Notifier<WorkScheduleState> {
  late final GetEmployeeShiftsUseCase _getEmployeeShiftsUseCase;

  @override
  WorkScheduleState build() {
    _getEmployeeShiftsUseCase = ref.read(getEmployeeShiftsUseCaseProvider);
    return WorkScheduleState();
  }

  Future<void> loadShifts({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final authState = ref.read(loginControllerProvider);
    final employeeIdStr = authState.user?.employeeId;
    final employeeId = employeeIdStr != null ? int.tryParse(employeeIdStr) : null;

    final result = await _getEmployeeShiftsUseCase(
      GetEmployeeShiftsParams(
        fromDate: fromDate,
        toDate: toDate,
        employeeId: employeeId,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (shifts) {
        state = state.copyWith(
          isLoading: false,
          shifts: shifts,
        );
      },
    );
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void setFocusedDate(DateTime date) {
    state = state.copyWith(focusedDate: date);
  }

  List<EmployeeShiftEntity> getShiftsForDate(DateTime date) {
    final dateStr = date.toIso8601String().split('T')[0];
    return state.shifts.where((shift) {
      final shiftDateStr = shift.shiftDate.toIso8601String().split('T')[0];
      return shiftDateStr == dateStr;
    }).toList();
  }
}

