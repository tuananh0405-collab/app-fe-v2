import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/create_leave_request_usecase.dart';
import '../../domain/usecases/get_leave_balance_usecase.dart';
import '../../domain/usecases/get_leave_record_by_id_usecase.dart';
import '../../domain/usecases/get_leave_records_usecase.dart';
import '../../domain/usecases/update_leave_request_usecase.dart';
import '../../domain/usecases/cancel_leave_request_usecase.dart';
import '../../providers/leave_providers.dart';
import '../state/leave_state.dart';

class LeaveController extends Notifier<LeaveState> {
  late final CreateLeaveRequestUseCase _createLeaveRequestUseCase;
  late final GetLeaveRecordsUseCase _getLeaveRecordsUseCase;
  late final GetLeaveBalanceUseCase _getLeaveBalanceUseCase;
  late final UpdateLeaveRequestUseCase _updateLeaveRequestUseCase;
  late final GetLeaveRecordByIdUseCase _getLeaveRecordByIdUseCase;
  late final CancelLeaveRequestUseCase _cancelLeaveRequestUseCase;

  @override
  LeaveState build() {
    _createLeaveRequestUseCase = ref.read(createLeaveRequestUseCaseProvider);
    _getLeaveRecordsUseCase = ref.read(getLeaveRecordsUseCaseProvider);
    _getLeaveBalanceUseCase = ref.read(getLeaveBalanceUseCaseProvider);
    _updateLeaveRequestUseCase = ref.read(updateLeaveRequestUseCaseProvider);
    _getLeaveRecordByIdUseCase = ref.read(getLeaveRecordByIdUseCaseProvider);
    _cancelLeaveRequestUseCase = ref.read(cancelLeaveRequestUseCaseProvider);
    return const LeaveState();
  }

  Future<void> createLeaveRequest({
    required int employeeId,
    required String employeeCode,
    required int departmentId,
    required int leaveTypeId,
    required DateTime startDate,
    required DateTime endDate,
    required bool isHalfDayStart,
    required bool isHalfDayEnd,
    required String reason,
    String? supportingDocumentUrl,
    Map<String, dynamic>? metadata,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true);

    final result = await _createLeaveRequestUseCase(
      CreateLeaveRequestParams(
        employeeId: employeeId,
        employeeCode: employeeCode,
        departmentId: departmentId,
        leaveTypeId: leaveTypeId,
        startDate: startDate,
        endDate: endDate,
        isHalfDayStart: isHalfDayStart,
        isHalfDayEnd: isHalfDayEnd,
        reason: reason,
        supportingDocumentUrl: supportingDocumentUrl,
        metadata: metadata,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        );
      },
      (leave) {
        state = state.copyWith(
          isSubmitting: false,
          successMessage: 'Đơn xin nghỉ đã được tạo thành công',
        );
        // Refresh leave records after creating
        getLeaveRecords();
      },
    );
  }

  Future<void> getLeaveRecords() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getLeaveRecordsUseCase(const NoParams());

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (records) {
        state = state.copyWith(
          isLoading: false,
          leaveRecords: records,
        );
      },
    );
  }

  Future<void> getLeaveBalance({required int employeeId}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getLeaveBalanceUseCase(
      GetLeaveBalanceParams(employeeId: employeeId),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (balances) {
        state = state.copyWith(
          isLoading: false,
          leaveBalances: balances,
        );
      },
    );
  }

  Future<void> updateLeaveRequest({
    required int leaveId,
    required int employeeId,
    required String employeeCode,
    required int departmentId,
    required int leaveTypeId,
    required DateTime startDate,
    required DateTime endDate,
    required bool isHalfDayStart,
    required bool isHalfDayEnd,
    required String reason,
    String? supportingDocumentUrl,
    Map<String, dynamic>? metadata,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true);

    final result = await _updateLeaveRequestUseCase(
      UpdateLeaveRequestParams(
        leaveId: leaveId,
        employeeId: employeeId,
        employeeCode: employeeCode,
        departmentId: departmentId,
        leaveTypeId: leaveTypeId,
        startDate: startDate,
        endDate: endDate,
        isHalfDayStart: isHalfDayStart,
        isHalfDayEnd: isHalfDayEnd,
        reason: reason,
        supportingDocumentUrl: supportingDocumentUrl,
        metadata: metadata,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        );
      },
      (leave) {
        state = state.copyWith(
          isSubmitting: false,
          successMessage: 'Đơn xin nghỉ đã được cập nhật thành công',
        );
        // Refresh leave records after updating
        getLeaveRecords();
      },
    );
  }

  Future<void> selectLeave(int leaveId) async {
    // Set loading state
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getLeaveRecordByIdUseCase(
      GetLeaveRecordByIdParams(leaveId: leaveId),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (leave) {
        state = state.copyWith(
          isLoading: false,
          selectedLeave: leave,
        );
      },
    );
  }

  void clearSelectedLeave() {
    state = state.copyWith(clearSelected: true);
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }

  Future<void> cancelLeaveRequest({
    required int leaveId,
    required String cancellationReason,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true);

    final result = await _cancelLeaveRequestUseCase(
      CancelLeaveRequestParams(
        leaveId: leaveId,
        cancellationReason: cancellationReason,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        );
      },
      (leave) {
        state = state.copyWith(
          isSubmitting: false,
          successMessage: 'Leave request has been cancelled successfully',
          selectedLeave: leave,
        );
        // Refresh leave records after canceling
        getLeaveRecords();
      },
    );
  }
}
