class ApiConstants {
  // Base URL - thay đổi theo môi trường
  // static const String baseUrl = 'http://10.0.2.2:3001/api/v1';
  static const String baseUrl = 'http://3.27.15.166:32527/api/v1';
  static const String authBaseUrl = 'http://3.27.15.166:32527/api/v1/auth';
  static const String attendanceBaseUrl = 'http://3.27.15.166:32527/attendance/api/v1';
  static const String employeeBaseUrl = 'http://3.27.15.166:32527/employee/api/v1';
  static const String leaveBaseUrl = 'http://3.27.15.166:32527/leave/api/v1';
  static const String notificationBaseUrl = 'http://3.27.15.166:32527/api/v1';
  static const String reportingBaseUrl = 'http://3.27.15.166:32527/reporting/api/v1';
  static const String faceBaseUrl = 'http://3.27.15.166:32527/api/v1/face';

  // Auth Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String refreshTokenEndpoint = '/auth/refresh-token';
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
