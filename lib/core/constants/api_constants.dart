class ApiConstants {
  // Base URL - thay đổi theo môi trường
  static const String baseUrl = 'http://10.0.2.2:3001/api/v1';
  // static const String baseUrl = 'http://3.27.15.166:32527/api/v1';


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
