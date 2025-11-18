import '../../domain/entities/overtime_entity.dart';

class OvertimeState {
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;
  final List<OvertimeEntity> overtimeRequests;
  final OvertimeEntity? selectedOvertime;

  const OvertimeState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
    this.overtimeRequests = const [],
    this.selectedOvertime,
  });

  OvertimeState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    List<OvertimeEntity>? overtimeRequests,
    OvertimeEntity? selectedOvertime,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearSelected = false,
  }) {
    return OvertimeState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      overtimeRequests: overtimeRequests ?? this.overtimeRequests,
      selectedOvertime:
          clearSelected ? null : (selectedOvertime ?? this.selectedOvertime),
    );
  }
}
