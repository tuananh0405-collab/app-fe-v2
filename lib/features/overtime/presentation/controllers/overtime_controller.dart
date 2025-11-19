import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/create_overtime_request_usecase.dart';
import '../../domain/usecases/get_my_overtime_requests_usecase.dart';
import '../../domain/usecases/get_overtime_request_by_id_usecase.dart';
import '../../domain/usecases/update_overtime_request_usecase.dart';
import '../../domain/usecases/cancel_overtime_request_usecase.dart';
import '../../providers/overtime_providers.dart';
import '../state/overtime_state.dart';

class OvertimeController extends Notifier<OvertimeState> {
  late final CreateOvertimeRequestUseCase _createOvertimeRequestUseCase;
  late final GetMyOvertimeRequestsUseCase _getMyOvertimeRequestsUseCase;
  late final GetOvertimeRequestByIdUseCase _getOvertimeRequestByIdUseCase;
  late final UpdateOvertimeRequestUseCase _updateOvertimeRequestUseCase;
  late final CancelOvertimeRequestUseCase _cancelOvertimeRequestUseCase;

  @override
  OvertimeState build() {
    _createOvertimeRequestUseCase =
        ref.read(createOvertimeRequestUseCaseProvider);
    _getMyOvertimeRequestsUseCase =
        ref.read(getMyOvertimeRequestsUseCaseProvider);
    _getOvertimeRequestByIdUseCase =
        ref.read(getOvertimeRequestByIdUseCaseProvider);
    _updateOvertimeRequestUseCase =
        ref.read(updateOvertimeRequestUseCaseProvider);
    _cancelOvertimeRequestUseCase =
        ref.read(cancelOvertimeRequestUseCaseProvider);
    return const OvertimeState();
  }

  Future<void> createOvertimeRequest({
    required int shiftId,
    required DateTime overtimeDate,
    required DateTime startTime,
    required DateTime endTime,
    required double estimatedHours,
    required String reason,
  }) async {
    state = state.copyWith(
        isSubmitting: true, clearError: true, clearSuccess: true);

    final result = await _createOvertimeRequestUseCase(
      CreateOvertimeRequestParams(
        shiftId: shiftId,
        overtimeDate: overtimeDate,
        startTime: startTime,
        endTime: endTime,
        estimatedHours: estimatedHours,
        reason: reason,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        );
      },
      (overtime) {
        state = state.copyWith(
          isSubmitting: false,
          successMessage: 'Đơn làm thêm giờ đã được tạo thành công',
        );
        // Refresh overtime requests after creating
        getMyOvertimeRequests();
      },
    );
  }

  Future<void> getMyOvertimeRequests({
    int limit = 20,
    int offset = 0,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getMyOvertimeRequestsUseCase(
      GetMyOvertimeRequestsParams(limit: limit, offset: offset),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (requests) {
        state = state.copyWith(
          isLoading: false,
          overtimeRequests: requests,
        );
      },
    );
  }

  Future<void> getOvertimeRequestById(int overtimeId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getOvertimeRequestByIdUseCase(
      GetOvertimeRequestByIdParams(overtimeId: overtimeId),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (overtime) {
        state = state.copyWith(
          isLoading: false,
          selectedOvertime: overtime,
        );
      },
    );
  }

  Future<void> updateOvertimeRequest({
    required int overtimeId,
    required int shiftId,
    required DateTime overtimeDate,
    required DateTime startTime,
    required DateTime endTime,
    required double estimatedHours,
    required String reason,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      clearError: true,
      clearSuccess: true,
    );

    final result = await _updateOvertimeRequestUseCase(
      UpdateOvertimeRequestParams(
        overtimeId: overtimeId,
        shiftId: shiftId,
        overtimeDate: overtimeDate,
        startTime: startTime,
        endTime: endTime,
        estimatedHours: estimatedHours,
        reason: reason,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(
          isSubmitting: false,
          successMessage: 'Đơn làm thêm giờ đã được cập nhật thành công',
        );
        // Refresh overtime requests after updating
        getMyOvertimeRequests();
      },
    );
  }

  Future<void> cancelOvertimeRequest(int overtimeId) async {
    state = state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true);
    final result = await _cancelOvertimeRequestUseCase(overtimeId);
    result.fold(
      (failure) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        );
      },
      (_) {
        state = state.copyWith(
          isSubmitting: false,
          successMessage: 'Hủy đơn làm thêm thành công',
        );
        getMyOvertimeRequests();
      },
    );
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}
