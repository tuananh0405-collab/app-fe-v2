import '../../domain/entities/employee_shift_entity.dart';

class WorkScheduleState {
  final bool isLoading;
  final String? errorMessage;
  final List<EmployeeShiftEntity> shifts;
  final DateTime selectedDate;
  final DateTime focusedDate;

  WorkScheduleState({
    this.isLoading = false,
    this.errorMessage,
    this.shifts = const [],
    DateTime? selectedDate,
    DateTime? focusedDate,
  })  : selectedDate = selectedDate ?? DateTime.now(),
        focusedDate = focusedDate ?? DateTime.now();

  WorkScheduleState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<EmployeeShiftEntity>? shifts,
    DateTime? selectedDate,
    DateTime? focusedDate,
    bool clearError = false,
  }) {
    return WorkScheduleState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      shifts: shifts ?? this.shifts,
      selectedDate: selectedDate ?? this.selectedDate,
      focusedDate: focusedDate ?? this.focusedDate,
    );
  }
}

