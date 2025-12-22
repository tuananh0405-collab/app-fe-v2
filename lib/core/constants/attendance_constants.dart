/// Attendance time flexibility constants
class AttendanceTimeFlexibility {
  // Check-in flexibility
  static const int earlyCheckInMinutes = 60; // 1 hour early
  static const int lateCheckInMinutes = 60; // 1 hour late
  
  // Check-out flexibility
  static const int earlyCheckOutMinutes = 30; // 30 minutes early
  static const int lateCheckOutMinutes = 60; // 1 hour late
  
  AttendanceTimeFlexibility._(); // Private constructor to prevent instantiation
}
