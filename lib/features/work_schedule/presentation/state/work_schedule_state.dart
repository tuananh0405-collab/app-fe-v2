import '../../domain/entities/employee_shift_entity.dart';
import '../../../leave/domain/entities/leave_entity.dart';
import '../../../leave/domain/entities/leave_type_entity.dart';
import '../../../overtime/domain/entities/overtime_entity.dart';
import '../../../holiday/domain/entities/holiday_entity.dart';

class WorkScheduleState {
  final bool isLoading;
  final String? errorMessage;
  final List<EmployeeShiftEntity> shifts;
  final List<LeaveEntity> leaves;
  final List<HolidayEntity> holidays;
  final List<OvertimeEntity> overtimes;
  final List<LeaveTypeEntity> leaveTypes;
  final DateTime selectedDate;
  final DateTime focusedDate;

  WorkScheduleState({
    this.isLoading = false,
    this.errorMessage,
    this.shifts = const [],
    this.leaves = const [],
    this.holidays = const [],
    this.overtimes = const [],
    this.leaveTypes = const [],
    DateTime? selectedDate,
    DateTime? focusedDate,
  })  : selectedDate = selectedDate ?? DateTime.now(),
        focusedDate = focusedDate ?? DateTime.now();

  WorkScheduleState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<EmployeeShiftEntity>? shifts,
    List<LeaveEntity>? leaves,
    List<HolidayEntity>? holidays,
    List<OvertimeEntity>? overtimes,
    List<LeaveTypeEntity>? leaveTypes,
    DateTime? selectedDate,
    DateTime? focusedDate,
    bool clearError = false,
  }) {
    return WorkScheduleState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      shifts: shifts ?? this.shifts,
      leaves: leaves ?? this.leaves,
      holidays: holidays ?? this.holidays,
      overtimes: overtimes ?? this.overtimes,
      leaveTypes: leaveTypes ?? this.leaveTypes,
      selectedDate: selectedDate ?? this.selectedDate,
      focusedDate: focusedDate ?? this.focusedDate,
    );
  }
}

