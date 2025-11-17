enum NotificationType {
  // Attendance related
  attendanceReminder('ATTENDANCE_REMINDER'),
  attendanceLateWarning('ATTENDANCE_LATE_WARNING'),
  attendanceAbsenceWarning('ATTENDANCE_ABSENCE_WARNING'),
  attendanceReport('ATTENDANCE_REPORT'),

  // Leave related
  leaveRequestSubmitted('LEAVE_REQUEST_SUBMITTED'),
  leaveRequestApproved('LEAVE_REQUEST_APPROVED'),
  leaveRequestRejected('LEAVE_REQUEST_REJECTED'),
  leaveRequestUpdated('LEAVE_REQUEST_UPDATED'),
  leaveBalanceLow('LEAVE_BALANCE_LOW'),

  // Face recognition
  faceVerificationRequest('FACE_VERIFICATION_REQUEST'),
  faceVerificationSuccess('FACE_VERIFICATION_SUCCESS'),
  faceVerificationFailed('FACE_VERIFICATION_FAILED'),

  // System
  systemAnnouncement('SYSTEM_ANNOUNCEMENT'),
  systemMaintenance('SYSTEM_MAINTENANCE'),
  passwordReset('PASSWORD_RESET'),
  accountLocked('ACCOUNT_LOCKED'),

  // Employee
  employeeBirthday('EMPLOYEE_BIRTHDAY'),
  employeeAnniversary('EMPLOYEE_ANNIVERSARY'),
  payrollAvailable('PAYROLL_AVAILABLE'),

  // Special
  all('ALL');

  final String value;
  
  const NotificationType(this.value);

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.all,
    );
  }

  @override
  String toString() => value;
}
