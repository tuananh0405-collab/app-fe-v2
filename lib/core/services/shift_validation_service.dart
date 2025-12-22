import '../constants/attendance_constants.dart';
import '../../features/work_schedule/domain/entities/employee_shift_entity.dart';

/// Result of shift validation
class ShiftValidationResult {
  final bool isValid;
  final String? errorMessage;
  final EmployeeShiftEntity? validShift;
  final String? attendanceType; // 'check_in' or 'check_out'
  
  const ShiftValidationResult({
    required this.isValid,
    this.errorMessage,
    this.validShift,
    this.attendanceType,
  });
  
  factory ShiftValidationResult.noShift() {
    return const ShiftValidationResult(
      isValid: false,
      errorMessage: 'No active shift available for check-in/check-out at this time.',
    );
  }
  
  factory ShiftValidationResult.valid({
    required EmployeeShiftEntity shift,
    required String attendanceType,
  }) {
    return ShiftValidationResult(
      isValid: true,
      validShift: shift,
      attendanceType: attendanceType,
    );
  }
}

/// Service to validate if current time is within allowed shift check-in/check-out window
class ShiftValidationService {
  ShiftValidationService._();
  
  /// Validates if there's a valid shift for check-in or check-out at current time
  /// 
  /// Returns [ShiftValidationResult] with validation status and shift details
  static ShiftValidationResult validateCurrentShift(List<EmployeeShiftEntity> todayShifts) {
    if (todayShifts.isEmpty) {
      return ShiftValidationResult.noShift();
    }
    
    final now = DateTime.now();
    
    // Sort shifts by scheduled start time
    final sortedShifts = List<EmployeeShiftEntity>.from(todayShifts);
    sortedShifts.sort((a, b) {
      final timeA = _parseTime(a.scheduledStartTime);
      final timeB = _parseTime(b.scheduledStartTime);
      return timeA.compareTo(timeB);
    });
    
    // Check each shift for valid check-in or check-out window
    for (final shift in sortedShifts) {
      // Parse shift times
      final shiftDate = shift.shiftDate;
      final startTime = _parseTime(shift.scheduledStartTime);
      final endTime = _parseTime(shift.scheduledEndTime);
      
      final shiftStart = DateTime(
        shiftDate.year,
        shiftDate.month,
        shiftDate.day,
        startTime.hour,
        startTime.minute,
      );
      
      final shiftEnd = DateTime(
        shiftDate.year,
        shiftDate.month,
        shiftDate.day,
        endTime.hour,
        endTime.minute,
      );
      
      // Check if within check-in window
      final checkInResult = _isWithinCheckInWindow(now, shiftStart, shift);
      if (checkInResult != null) {
        return checkInResult;
      }
      
      // Check if within check-out window
      final checkOutResult = _isWithinCheckOutWindow(now, shiftEnd, shift);
      if (checkOutResult != null) {
        return checkOutResult;
      }
    }
    
    return ShiftValidationResult.noShift();
  }
  
  /// Check if current time is within check-in window
  /// Check-in window: [shift start - 1 hour] to [shift start + 1 hour]
  static ShiftValidationResult? _isWithinCheckInWindow(
    DateTime now,
    DateTime shiftStart,
    EmployeeShiftEntity shift,
  ) {
    // Skip if already checked in
    if (shift.checkInTime != null) {
      return null;
    }
    
    final earlyCheckInTime = shiftStart.subtract(
      Duration(minutes: AttendanceTimeFlexibility.earlyCheckInMinutes),
    );
    final lateCheckInTime = shiftStart.add(
      Duration(minutes: AttendanceTimeFlexibility.lateCheckInMinutes),
    );
    
    if (now.isAfter(earlyCheckInTime) && now.isBefore(lateCheckInTime)) {
      return ShiftValidationResult.valid(
        shift: shift,
        attendanceType: 'check_in',
      );
    }
    
    return null;
  }
  
  /// Check if current time is within check-out window
  /// Check-out window: [shift end - 30 minutes] to [shift end + 1 hour]
  static ShiftValidationResult? _isWithinCheckOutWindow(
    DateTime now,
    DateTime shiftEnd,
    EmployeeShiftEntity shift,
  ) {
    // Can only check out if already checked in
    if (shift.checkInTime == null) {
      return null;
    }
    
    // Skip if already checked out
    if (shift.checkOutTime != null) {
      return null;
    }
    
    final earlyCheckOutTime = shiftEnd.subtract(
      Duration(minutes: AttendanceTimeFlexibility.earlyCheckOutMinutes),
    );
    final lateCheckOutTime = shiftEnd.add(
      Duration(minutes: AttendanceTimeFlexibility.lateCheckOutMinutes),
    );
    
    if (now.isAfter(earlyCheckOutTime) && now.isBefore(lateCheckOutTime)) {
      return ShiftValidationResult.valid(
        shift: shift,
        attendanceType: 'check_out',
      );
    }
    
    return null;
  }
  
  /// Parse time string (HH:mm:ss or HH:mm) to DateTime
  static DateTime _parseTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    return DateTime(0, 1, 1, hour, minute);
  }
}
