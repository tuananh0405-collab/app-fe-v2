import '../../domain/entities/leave_balance_entity.dart';
import '../../domain/entities/leave_entity.dart';

class LeaveState {
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;
  final List<LeaveEntity> leaveRecords;
  final List<LeaveBalanceEntity> leaveBalances;
  final LeaveEntity? selectedLeave;

  const LeaveState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
    this.leaveRecords = const [],
    this.leaveBalances = const [],
    this.selectedLeave,
  });

  LeaveState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    List<LeaveEntity>? leaveRecords,
    List<LeaveBalanceEntity>? leaveBalances,
    LeaveEntity? selectedLeave,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearSelected = false,
  }) {
    return LeaveState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      leaveRecords: leaveRecords ?? this.leaveRecords,
      leaveBalances: leaveBalances ?? this.leaveBalances,
      selectedLeave: clearSelected ? null : (selectedLeave ?? this.selectedLeave),
    );
  }
}
