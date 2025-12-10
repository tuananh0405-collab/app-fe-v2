import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/employee_shift_api_response_model.dart';
import '../models/employee_shift_model.dart';
import '../../domain/entities/employee_shift_entity.dart';

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
            final assignments = response.data['data'] as List;

            for (var date = futureStartDate;
                date.isBefore(toDate.add(const Duration(days: 1)));
                date = date.add(const Duration(days: 1))) {
              
              final dateOnly = DateTime(date.year, date.month, date.day);

              // Find assignment for this date
              final assignment = assignments.firstWhere((a) {
                final effectiveFrom = DateTime.parse(a['effective_from']);
                final effectiveTo = DateTime.parse(a['effective_to']);
                
                final efOnly = DateTime(effectiveFrom.year, effectiveFrom.month, effectiveFrom.day);
                final etOnly = DateTime(effectiveTo.year, effectiveTo.month, effectiveTo.day);

                return (dateOnly.isAtSameMomentAs(efOnly) || dateOnly.isAfter(efOnly)) &&
                       (dateOnly.isAtSameMomentAs(etOnly) || dateOnly.isBefore(etOnly));
              }, orElse: () => null);

              if (assignment != null) {
                final schedule = assignment['work_schedule'];
                if (schedule != null) {
                  allShifts.add(EmployeeShiftModel(
                    id: 0,
                    employeeId: employeeId,
                    employeeCode: '', 
                    departmentId: 0,
                    shiftDate: date,
                    workScheduleId: schedule['id'] ?? 0,
                    scheduledStartTime: schedule['start_time'] ?? '00:00:00',
                    scheduledEndTime: schedule['end_time'] ?? '00:00:00',
                    status: ShiftStatus.scheduled,
                    scheduleName: schedule['schedule_name'],
                  ));
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
    final processedShifts = allShifts.map((shift) {
      // Only process shifts with scheduled status
      if (shift.status == ShiftStatus.scheduled) {
        // Parse the scheduled start time to get check-in time
        final timeParts = shift.scheduledStartTime.split(':');
        final checkInDateTime = DateTime(
          shift.shiftDate.year,
          shift.shiftDate.month,
          shift.shiftDate.day,
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
          timeParts.length > 2 ? int.parse(timeParts[2]) : 0,
        );

        // If check-in time has passed, change status to inProgress
        if (now.isAfter(checkInDateTime) || now.isAtSameMomentAs(checkInDateTime)) {
          return EmployeeShiftModel(
            id: shift.id,
            employeeId: shift.employeeId,
            employeeCode: shift.employeeCode,
            departmentId: shift.departmentId,
            shiftDate: shift.shiftDate,
            workScheduleId: shift.workScheduleId,
            scheduledStartTime: shift.scheduledStartTime,
            scheduledEndTime: shift.scheduledEndTime,
            checkInTime: shift.checkInTime,
            checkOutTime: shift.checkOutTime,
            workHours: shift.workHours,
            overtimeHours: shift.overtimeHours,
            breakHours: shift.breakHours,
            lateMinutes: shift.lateMinutes,
            earlyLeaveMinutes: shift.earlyLeaveMinutes,
            status: ShiftStatus.inProgress,
            notes: shift.notes,
            scheduleName: shift.scheduleName,
          );
        }
      }
      return shift;
    }).toList();

    return processedShifts;
  }
}

