class AppRouteName {
  static const signIn = 'sign-in';
  static const home = 'home';

  // Attendance
  static const attendanceCheck = 'attendance-check';
  static const attendanceReport = 'attendance-report';

  // Leaves
  static const leaves = 'leaves';
  static const leavesCreate = 'leaves-create';
  static const leaveDetail = 'leave-detail';
  static const leaveEdit = 'leave-edit';

  // Overtimes
  static const overtimesCreate = 'overtimes-create';
  static const overtimeDetail = 'overtime-detail';
  static const overtimeEdit = 'overtime-edit';

  // Notifications
  static const notifications = 'notifications';
  static const notificationsManage = 'notifications-manage';

  // Profile
  static const profile = 'profile';
  static const profileView = 'profile-view';
  static const profileContract = 'profile-contract';

  // Devices & FaceID
  static const devices = 'devices';
  static const deviceRegister = 'device-register';
  static const deviceEdit = 'device-edit';
  static const faceIdRegister = 'faceid-register';

  // Schedule
  static const schedule = 'schedule';

  // Settings
  static const settings = 'settings';
}

class AppRoutePath {
  static const signIn = '/sign-in';
  static const home = '/home';

  // Attendance
  static const attendanceCheck = '/attendance/check';
  static const attendanceReport = '/attendance/report';

  // Leaves
  static const leaves = '/leaves';
  static const leavesCreate = '/leaves/create';
  static String leaveDetail(String id) => '/leaves/$id';
  static String leaveEdit(String id) => '/leaves/$id/edit';

  // Overtimes
  static const overtimesCreate = '/overtimes/create';
  static String overtimeDetail(String id) => '/overtimes/$id';
  static String overtimeEdit(String id) => '/overtimes/$id/edit';

  // Notifications
  static const notifications = '/notifications';
  static const notificationsManage = '/notifications/manage';

  // Profile
  static const profile = '/profile';
  static const profileView = '/profile/view';
  static const profileContract = '/profile/contract';

  // Devices & FaceID
  static const devices = '/devices';
  static const deviceRegister = '/devices/register';
  static String deviceEdit(String id) => '/devices/$id/edit';
  static const faceIdRegister = '/faceid/register';

  // Schedule
  static const schedule = '/schedule';

  // Settings
  static const settings = '/settings';
}
