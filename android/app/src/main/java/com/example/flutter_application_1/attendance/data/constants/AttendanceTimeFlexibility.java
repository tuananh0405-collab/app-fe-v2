package com.example.flutter_application_1.attendance.data.constants;

/**
 * Constants for attendance time flexibility windows
 */
public class AttendanceTimeFlexibility {
    // Check-in flexibility (in minutes)
    public static final int EARLY_CHECK_IN_MINUTES = 60;  // 1 hour early
    public static final int LATE_CHECK_IN_MINUTES = 60;   // 1 hour late
    
    // Check-out flexibility (in minutes)
    public static final int EARLY_CHECK_OUT_MINUTES = 30; // 30 minutes early
    public static final int LATE_CHECK_OUT_MINUTES = 60;  // 1 hour late
    
    private AttendanceTimeFlexibility() {
        // Private constructor to prevent instantiation
    }
}
