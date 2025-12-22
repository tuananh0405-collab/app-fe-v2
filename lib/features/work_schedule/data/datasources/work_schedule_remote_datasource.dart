import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/employee_shift_api_response_model.dart';
import '../models/employee_shift_model.dart';
import '../models/work_schedule_assignment_model.dart';
import '../../domain/entities/employee_shift_entity.dart';
import '../../domain/entities/work_schedule_assignment_entity.dart';

abstract class WorkScheduleRemoteDataSource {
  Future<List<EmployeeShiftModel>> getEmployeeShifts({
    required DateTime fromDate,
    required DateTime toDate,
    int? employeeId,
  });
}

class WorkScheduleRemoteDataSourceImpl
    implements WorkScheduleRemoteDataSource {
  final Dio dio;

  WorkScheduleRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<EmployeeShiftModel>> getEmployeeShifts({
    required DateTime fromDate,
    required DateTime toDate,
    int? employeeId,
  }) async {
    final List<EmployeeShiftModel> allShifts = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 1. Fetch past/today shifts
    if (fromDate.isBefore(today.add(const Duration(days: 1)))) {
      final effectiveToDate = toDate.isBefore(today) ? toDate : today;
      
      try {
        final fromDateStr = fromDate.toIso8601String().split('T')[0];
        // Add 1 day to toDate to ensure we get all shifts for today (API uses exclusive end date)
        final toDateStr = effectiveToDate.add(const Duration(days: 1)).toIso8601String().split('T')[0];

        final response = await dio.get(
          '/attendance/employee-shifts/my',
          queryParameters: {
            'from_date': fromDateStr,
            'to_date': toDateStr,
            'page': 1,
            'limit': 100,
          },
        );

        final apiResponse = EmployeeShiftApiResponseModel.fromJson(
          response.data,
          (data) => EmployeeShiftModel.fromJson(data as Map<String, dynamic>),
        );

        if (response.statusCode == 200) {
          if (apiResponse.data != null && apiResponse.data!.data.isNotEmpty) {
            allShifts.addAll(apiResponse.data!.data.cast<EmployeeShiftModel>());
          }
        } else if (response.statusCode == 401) {
          throw UnauthorizedException(apiResponse.message);
        } else {
          throw ServerException(apiResponse.message);
        }
      } on DioException catch (e) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          throw const NetworkException('Connection timeout');
        } else if (e.type == DioExceptionType.connectionError) {
          throw const NetworkException('No internet connection');
        } else if (e.response != null) {
          throw ServerException(
            e.response?.data['message'] ?? 'Server error occurred',
          );
        } else {
          throw const ServerException('Failed to connect to server');
        }
      } catch (e) {
        if (e is UnauthorizedException ||
            e is ServerException ||
            e is NetworkException) {
          rethrow;
        }
        throw ServerException('Unexpected error: ${e.toString()}');
      }
    }

    // 2. Fetch future shifts
    if (toDate.isAfter(today)) {
      final futureStartDate = fromDate.isAfter(today) 
          ? fromDate 
          : today.add(const Duration(days: 1));

      if (employeeId != null) {
        try {
          final response = await dio.get(
            '/attendance/work-schedules/assignments/employee/$employeeId',
          );

          if (response.statusCode == 200 && response.data['data'] != null) {
            final assignmentsJson = response.data['data'] as List;
            
            // Parse assignments
            final assignments = assignmentsJson
                .map((json) => WorkScheduleAssignmentModel.fromJson(json))
                .toList();

            // Iterate through each date in the range
            for (var date = futureStartDate;
                date.isBefore(toDate.add(const Duration(days: 1)));
                date = date.add(const Duration(days: 1))) {
              
              final dateOnly = DateTime(date.year, date.month, date.day);

              // Find all assignments that cover this date
              final applicableAssignments = assignments.where((assignment) {
                final efOnly = DateTime(
                  assignment.effectiveFrom.year,
                  assignment.effectiveFrom.month,
                  assignment.effectiveFrom.day,
                );
                final etOnly = DateTime(
                  assignment.effectiveTo.year,
                  assignment.effectiveTo.month,
                  assignment.effectiveTo.day,
                );

                return (dateOnly.isAtSameMomentAs(efOnly) || dateOnly.isAfter(efOnly)) &&
                       (dateOnly.isAtSameMomentAs(etOnly) || dateOnly.isBefore(etOnly));
              }).toList();

              // Process each applicable assignment (can have multiple shifts per day)
              for (var assignment in applicableAssignments) {
                EmployeeShiftModel? shiftForAssignment;
                
                // Check if there's a schedule override for this date
                final override = assignment.scheduleOverrides.cast<ScheduleOverrideEntity?>().firstWhere(
                  (override) {
                    if (override == null) return false;
                    final overrideFromDate = DateTime(
                      override.fromDate.year,
                      override.fromDate.month,
                      override.fromDate.day,
                    );
                    final overrideToDate = DateTime(
                      override.toDate.year,
                      override.toDate.month,
                      override.toDate.day,
                    );

                    return (dateOnly.isAtSameMomentAs(overrideFromDate) || 
                            dateOnly.isAfter(overrideFromDate)) &&
                           (dateOnly.isAtSameMomentAs(overrideToDate) || 
                            dateOnly.isBefore(overrideToDate));
                  },
                  orElse: () => null,
                );

                if (override != null && override.overrideWorkScheduleId != null) {
                  // Find the override work schedule from all assignments
                  WorkScheduleEntity? overrideSchedule;
                  
                  for (var otherAssignment in assignments) {
                    if (otherAssignment.workScheduleId == override.overrideWorkScheduleId) {
                      overrideSchedule = otherAssignment.workSchedule;
                      break;
                    }
                  }

                  if (overrideSchedule != null) {
                    shiftForAssignment = EmployeeShiftModel(
                      id: 0,
                      employeeId: employeeId,
                      employeeCode: '', 
                      departmentId: 0,
                      shiftDate: date,
                      workScheduleId: overrideSchedule.id,
                      scheduledStartTime: overrideSchedule.startTime,
                      scheduledEndTime: overrideSchedule.endTime,
                      status: ShiftStatus.scheduled,
                      scheduleName: '${overrideSchedule.scheduleName} (Override)',
                    );
                  }
                } else {
                  // No override, use the regular work schedule
                  final schedule = assignment.workSchedule;
                  
                  shiftForAssignment = EmployeeShiftModel(
                    id: 0,
                    employeeId: employeeId,
                    employeeCode: '', 
                    departmentId: 0,
                    shiftDate: date,
                    workScheduleId: schedule.id,
                    scheduledStartTime: schedule.startTime,
                    scheduledEndTime: schedule.endTime,
                    status: ShiftStatus.scheduled,
                    scheduleName: schedule.scheduleName,
                  );
                }

                if (shiftForAssignment != null) {
                  allShifts.add(shiftForAssignment);
                }
              }
            }
          }
        } catch (e) {
           // Handle errors for future shifts
           if (e is DioException) {
             // Log or rethrow? 
             // If we fail here, we might want to throw to alert the user.
             if (e.response != null) {
                throw ServerException(e.response?.data['message'] ?? 'Server error occurred');
             }
           }
           throw ServerException('Failed to load future shifts: ${e.toString()}');
        }
      }
    }

    // 3. Process shifts to update status from scheduled to inProgress if check-in time has passed
    // NOTE: Logic này đã được comment để sử dụng status từ BE trực tiếp
    // Có thể sẽ dùng lại sau này nếu cần xử lý status ở client-side
    // final processedShifts = allShifts.map((shift) {
    //   // Only process shifts with scheduled status
    //   if (shift.status == ShiftStatus.scheduled) {
    //     // Parse the scheduled start time to get check-in time
    //     final timeParts = shift.scheduledStartTime.split(':');
    //     final checkInDateTime = DateTime(
    //       shift.shiftDate.year,
    //       shift.shiftDate.month,
    //       shift.shiftDate.day,
    //       int.parse(timeParts[0]),
    //       int.parse(timeParts[1]),
    //       timeParts.length > 2 ? int.parse(timeParts[2]) : 0,
    //     );
    //
    //     // Parse the scheduled end time to get check-out time
    //     final endTimeParts = shift.scheduledEndTime.split(':');
    //     final checkOutDateTime = DateTime(
    //       shift.shiftDate.year,
    //       shift.shiftDate.month,
    //       shift.shiftDate.day,
    //       int.parse(endTimeParts[0]),
    //       int.parse(endTimeParts[1]),
    //       endTimeParts.length > 2 ? int.parse(endTimeParts[2]) : 0,
    //     );
    //
    //     // If check-in time has passed and now is before or at check-out time, change status to inProgress
    //     if ((now.isAfter(checkInDateTime) || now.isAtSameMomentAs(checkInDateTime)) &&
    //         (now.isBefore(checkOutDateTime) || now.isAtSameMomentAs(checkOutDateTime))) {
    //       return EmployeeShiftModel(
    //         id: shift.id,
    //         employeeId: shift.employeeId,
    //         employeeCode: shift.employeeCode,
    //         departmentId: shift.departmentId,
    //         shiftDate: shift.shiftDate,
    //         workScheduleId: shift.workScheduleId,
    //         scheduledStartTime: shift.scheduledStartTime,
    //         scheduledEndTime: shift.scheduledEndTime,
    //         checkInTime: shift.checkInTime,
    //         checkOutTime: shift.checkOutTime,
    //         workHours: shift.workHours,
    //         overtimeHours: shift.overtimeHours,
    //         breakHours: shift.breakHours,
    //         lateMinutes: shift.lateMinutes,
    //         earlyLeaveMinutes: shift.earlyLeaveMinutes,
    //         status: ShiftStatus.inProgress,
    //         notes: shift.notes,
    //         scheduleName: shift.scheduleName,
    //       );
    //     }
    //   }
    //   return shift;
    // }).toList();
    //
    // return processedShifts;

    // Hiện tại trả về status từ BE trực tiếp
    // Nếu BE trả về IN_PROGRESS thì sẽ hiển thị in progress
    return allShifts;
  }
}

