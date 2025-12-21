import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

/// JWT Helper
/// 
/// Decode JWT token để lấy thông tin user (bao gồm employee_id)
class JwtHelper {
  /// Decode JWT token và extract payload
  static Map<String, dynamic>? decodeToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        debugPrint('Invalid JWT token format');
        return null;
      }

      // Decode payload (part 2)
      final payload = parts[1];
      
      // Add padding if necessary
      var normalized = base64Url.normalize(payload);
      var decoded = utf8.decode(base64Url.decode(normalized));
      
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error decoding JWT: $e');
      return null;
    }
  }

  /// Get employee ID from JWT token
  static String? getEmployeeIdFromToken(String token) {
    final payload = decodeToken(token);
    if (payload == null) return null;

    // Backend JWT payload structure:
    // {
    //   "sub": "7",
    //   "email": "admin@gmail.com", 
    //   "employee_id": "10",
    //   "role": "ADMIN",
    //   "permissions": [...],
    //   "iat": 1764237975,
    //   "exp": 1764238875
    // }
    
    final employeeId = payload['employee_id'];
    return employeeId?.toString();
  }

  /// Get employee ID from stored access token
  static Future<String?> getEmployeeIdFromStorage() async {
    try {
      // Try to get access token from Hive
      final box = await Hive.openBox('authBox');
      final accessToken = box.get('accessToken') as String?;
      
      if (accessToken == null) {
        debugPrint('No access token found in storage');
        return null;
      }

      return getEmployeeIdFromToken(accessToken);
    } catch (e) {
      debugPrint('Error getting employee ID from storage: $e');
      return null;
    }
  }

  /// Get user ID (account ID) from JWT token
  static String? getUserIdFromToken(String token) {
    final payload = decodeToken(token);
    if (payload == null) return null;

    final sub = payload['sub'];
    return sub?.toString();
  }

  /// Get user email from JWT token
  static String? getEmailFromToken(String token) {
    final payload = decodeToken(token);
    if (payload == null) return null;

    return payload['email'] as String?;
  }

  /// Get user role from JWT token
  static String? getRoleFromToken(String token) {
    final payload = decodeToken(token);
    if (payload == null) return null;

    return payload['role'] as String?;
  }

  /// Check if token is expired
  static bool isTokenExpired(String token) {
    final payload = decodeToken(token);
    if (payload == null) return true;

    final exp = payload['exp'] as int?;
    if (exp == null) return true;

    final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return DateTime.now().isAfter(expiryDate);
  }
}
