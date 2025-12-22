import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/employee_shift_entity.dart';
import '../../domain/usecases/get_employee_shifts_usecase.dart';
import '../../providers/work_schedule_providers.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../leave/providers/leave_providers.dart';
import '../../../leave/domain/entities/leave_type_entity.dart';
import '../../../leave/domain/usecases/get_leave_records_usecase.dart';
import '../../../leave/domain/usecases/get_leave_types_usecase.dart';
import '../../../overtime/providers/overtime_providers.dart';
import '../../../overtime/domain/usecases/get_my_overtime_requests_usecase.dart';
import '../../../holiday/data/datasources/holiday_remote_datasource.dart';
import '../../../holiday/data/models/holiday_model.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/usecases/usecase.dart';
import '../state/work_schedule_state.dart';

class WorkScheduleController extends Notifier<WorkScheduleState> {
  late final GetEmployeeShiftsUseCase _getEmployeeShiftsUseCase;
  late final HolidayRemoteDataSource _holidayDataSource;

  @override
  WorkScheduleState build() {
    _getEmployeeShiftsUseCase = ref.read(getEmployeeShiftsUseCaseProvider);
    _holidayDataSource = HolidayRemoteDataSourceImpl(
      dio: ref.read(dioProvider),
    );
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

    print('[WorkSchedule] Loading shifts from $fromDate to $toDate');
    print('[WorkSchedule] Employee ID: $employeeId');

    try {
      // Fetch all data in parallel
      final results = await Future.wait([
        // 1. Fetch shifts
        _getEmployeeShiftsUseCase(
          GetEmployeeShiftsParams(
            fromDate: fromDate,
            toDate: toDate,
            employeeId: employeeId,
          ),
        ).then((result) {
          print('[WorkSchedule] Shifts result: ${result.fold((l) => 'Error: ${l.message}', (r) => '${r.length} shifts')}');
          return result.fold((l) => null, (r) => r);
        }),
        
        // 2. Fetch approved leave records
        ref.read(getLeaveRecordsUseCaseProvider)(
          const GetLeaveRecordsParams(status: 'APPROVED'),
        ).then((result) {
          print('[WorkSchedule] Leaves result: ${result.fold((l) => 'Error: ${l.message}', (r) => '${r.length} leaves')}');
          return result.fold((l) => null, (r) => r);
        }),
        
        // 3. Fetch holidays
        _holidayDataSource.getHolidays(limit: 100).then((holidays) {
          print('[WorkSchedule] Holidays result: ${holidays.length} holidays');
          return holidays;
        }).catchError((e) {
          print('[WorkSchedule] Holidays error: $e');
          return <HolidayModel>[];  // Return empty list of correct type
        }),
        
        // 4. Fetch approved overtime requests
        ref.read(getMyOvertimeRequestsUseCaseProvider)(
          const GetMyOvertimeRequestsParams(limit: 1000),
        ).then((result) {
          print('[WorkSchedule] Overtimes result: ${result.fold((l) => 'Error: ${l.message}', (r) => '${r.length} overtimes')}');
          return result.fold((l) => null, (r) => r);
        }),
        
        // 5. Fetch leave types for color mapping
        ref.read(getLeaveTypesUseCaseProvider)(
          const NoParams(),
        ).then((result) {
          print('[WorkSchedule] Leave types result: ${result.fold((l) => 'Error: ${l.message}', (r) => '${r.length} types')}');
          return result.fold((l) => null, (r) => r);
        }),
      ]);

      final shifts = results[0] as List<dynamic>?;
      final leaves = results[1] as List<dynamic>?;
      final holidays = results[2] as List<dynamic>;  // Non-nullable, returns empty list on error
      final overtimes = results[3] as List<dynamic>?;
      final leaveTypes = results[4] as List<dynamic>?;

      print('[WorkSchedule] Final results:');
      print('  - Shifts: ${shifts?.length ?? 0}');
      print('  - Leaves: ${leaves?.length ?? 0}');
      print('  - Holidays: ${holidays.length}');
      print('  - Overtimes: ${overtimes?.length ?? 0}');
      print('  - Leave Types: ${leaveTypes?.length ?? 0}');

      if (shifts == null) {
        print('[WorkSchedule] Failed to load shifts');
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load shifts',
        );
        return;
      }

      state = state.copyWith(
        isLoading: false,
        shifts: shifts.cast(),
        leaves: (leaves ?? []).cast(),
        holidays: holidays.cast(),  // No need for ?? since it's non-nullable
        overtimes: (overtimes ?? []).cast(),
        leaveTypes: (leaveTypes ?? []).cast(),
      );
      
      print('[WorkSchedule] State updated successfully');
    } catch (e, stackTrace) {
      print('[WorkSchedule] Exception: $e');
      print('Stack trace: $stackTrace');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void setFocusedDate(DateTime date) {
    state = state.copyWith(focusedDate: date);
  }

  List<EmployeeShiftEntity> getShiftsForDate(DateTime date) {
    return state.shifts.where((shift) {
      return shift.shiftDate.year == date.year &&
             shift.shiftDate.month == date.month &&
             shift.shiftDate.day == date.day;
    }).toList();
  }

  /// Check if a date is a holiday
  bool isHoliday(DateTime date) {
    final dateStr = date.toIso8601String().split('T')[0];
    return state.holidays.any((holiday) {
      final holidayDateStr = holiday.holidayDate.toIso8601String().split('T')[0];
      return holidayDateStr == dateStr;
    });
  }

  /// Check if employee has leave on a specific date
  bool hasLeaveOnDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return state.leaves.any((leave) {
      final startDate = DateTime(
        leave.startDate.year,
        leave.startDate.month,
        leave.startDate.day,
      );
      final endDate = DateTime(
        leave.endDate.year,
        leave.endDate.month,
        leave.endDate.day,
      );
      return (dateOnly.isAtSameMomentAs(startDate) || dateOnly.isAfter(startDate)) &&
             (dateOnly.isAtSameMomentAs(endDate) || dateOnly.isBefore(endDate));
    });
  }

  /// Get leave info for a specific date (returns leave entity and leave type)
  Map<String, dynamic>? getLeaveInfoForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    for (final leave in state.leaves) {
      final startDate = DateTime(
        leave.startDate.year,
        leave.startDate.month,
        leave.startDate.day,
      );
      final endDate = DateTime(
        leave.endDate.year,
        leave.endDate.month,
        leave.endDate.day,
      );
      
      if ((dateOnly.isAtSameMomentAs(startDate) || dateOnly.isAfter(startDate)) &&
          (dateOnly.isAtSameMomentAs(endDate) || dateOnly.isBefore(endDate))) {
        // Find corresponding leave type
        LeaveTypeEntity? leaveType;
        try {
          leaveType = state.leaveTypes.firstWhere(
            (type) => type.id == leave.leaveTypeId,
          );
        } catch (e) {
          leaveType = null;
        }
        
        return {
          'leave': leave,
          'leaveType': leaveType,
          'color': leaveType?.colorHex ?? '#8b5cf6', // Default purple
          'label': leaveType?.leaveTypeName ?? 'Leave',
        };
      }
    }
    
    return null;
  }

  /// Get holiday info for a specific date
  Map<String, dynamic>? getHolidayInfoForDate(DateTime date) {
    final dateStr = date.toIso8601String().split('T')[0];
    
    for (final holiday in state.holidays) {
      final holidayDateStr = holiday.holidayDate.toIso8601String().split('T')[0];
      if (holidayDateStr == dateStr) {
        return {
          'holiday': holiday,
          'label': 'Holiday: ${holiday.holidayName}',
          'color': '#6b7280', // gray-500
        };
      }
    }
    
    return null;
  }

  /// Get overtime requests for a specific date
  List<dynamic> getOvertimesForDate(DateTime date) {
    final dateStr = date.toIso8601String().split('T')[0];
    return state.overtimes.where((overtime) {
      final overtimeDateStr = overtime.overtimeDate.toIso8601String().split('T')[0];
      return overtimeDateStr == dateStr && overtime.status == 'APPROVED';
    }).toList();
  }
}

