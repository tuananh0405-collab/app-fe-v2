import '../../domain/entities/device_session_entity.dart';

class DeviceSessionModel extends DeviceSessionEntity {
  const DeviceSessionModel({
    required super.id,
    required super.accountId,
    super.employeeId,
    required super.deviceId,
    super.deviceName,
    super.deviceOs,
    super.deviceModel,
    super.deviceFingerprint,
    required super.platform,
    super.appVersion,
    super.isTrusted = false,
    super.trustedAt,
    super.trustedBy,
    super.trustVerificationMethod,
    required super.firstLoginAt,
    super.lastLoginAt,
    super.lastActiveAt,
    super.loginCount = 0,
    super.failedLoginAttempts = 0,
    super.lastFailedAt,
    super.lastIpAddress,
    super.lastLocation,
    super.lastUserAgent,
    super.networkType,
    super.fcmToken,
    super.fcmTokenUpdatedAt,
    super.fcmTokenStatus = FcmTokenStatus.other,
    super.status = DeviceStatus.other,
    super.revokedAt,
    super.revokedBy,
    super.revokeReason,
    super.expiresAt,
    super.createdAt,
    super.updatedAt,
  });

  factory DeviceSessionModel.fromJson(Map<String, dynamic> json) {
    final firstLogin =
        _parseDate(json['first_login_at']) ?? DateTime.fromMillisecondsSinceEpoch(0);

    return DeviceSessionModel(
      id: _parseInt(json['id']) ?? 0,
      accountId: _parseInt(json['account_id']) ?? 0,
      employeeId: _parseInt(json['employee_id']),
      deviceId: json['device_id']?.toString() ?? '',
      deviceName: json['device_name'] as String?,
      deviceOs: json['device_os'] as String?,
      deviceModel: json['device_model'] as String?,
      deviceFingerprint: json['device_fingerprint'] as String?,
      platform: DevicePlatform.fromValue(json['platform']?.toString()),
      appVersion: json['app_version'] as String?,
      isTrusted: _parseBool(json['is_trusted']),
      trustedAt: _parseDate(json['trusted_at']),
      trustedBy: _parseInt(json['trusted_by']),
      trustVerificationMethod: json['trust_verification_method'] as String?,
      firstLoginAt: firstLogin,
      lastLoginAt: _parseDate(json['last_login_at']),
      lastActiveAt: _parseDate(json['last_active_at']),
      loginCount: _parseInt(json['login_count']) ?? 0,
      failedLoginAttempts: _parseInt(json['failed_login_attempts']) ?? 0,
      lastFailedAt: _parseDate(json['last_failed_at']),
      lastIpAddress: json['last_ip_address'] as String?,
      lastLocation: _parseLocation(json['last_location']),
      lastUserAgent: json['last_user_agent'] as String?,
      networkType: json['network_type'] as String?,
      fcmToken: json['fcm_token'] as String?,
      fcmTokenUpdatedAt: _parseDate(json['fcm_token_updated_at']),
      fcmTokenStatus: FcmTokenStatus.fromValue(json['fcm_token_status']?.toString()),
      status: DeviceStatus.fromValue(json['status']?.toString()),
      revokedAt: _parseDate(json['revoked_at']),
      revokedBy: _parseInt(json['revoked_by']),
      revokeReason: json['revoke_reason'] as String?,
      expiresAt: _parseDate(json['expires_at']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account_id': accountId,
      'employee_id': employeeId,
      'device_id': deviceId,
      'device_name': deviceName,
      'device_os': deviceOs,
      'device_model': deviceModel,
      'device_fingerprint': deviceFingerprint,
      'platform': platform.value,
      'app_version': appVersion,
      'is_trusted': isTrusted,
      'trusted_at': trustedAt?.toIso8601String(),
      'trusted_by': trustedBy,
      'trust_verification_method': trustVerificationMethod,
      'first_login_at': firstLoginAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'last_active_at': lastActiveAt?.toIso8601String(),
      'login_count': loginCount,
      'failed_login_attempts': failedLoginAttempts,
      'last_failed_at': lastFailedAt?.toIso8601String(),
      'last_ip_address': lastIpAddress,
      'last_location': lastLocation == null
          ? null
          : {
              'latitude': lastLocation!.latitude,
              'longitude': lastLocation!.longitude,
            },
      'last_user_agent': lastUserAgent,
      'network_type': networkType,
      'fcm_token': fcmToken,
      'fcm_token_updated_at': fcmTokenUpdatedAt?.toIso8601String(),
      'fcm_token_status': fcmTokenStatus.value,
      'status': status.value,
      'revoked_at': revokedAt?.toIso8601String(),
      'revoked_by': revokedBy,
      'revoke_reason': revokeReason,
      'expires_at': expiresAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      return value == '1' ||
          value.toLowerCase() == 'true' ||
          value.toLowerCase() == 'yes';
    }
    return false;
  }

  static DeviceLocation? _parseLocation(dynamic value) {
    if (value is Map<String, dynamic>) {
      final lat = _parseDouble(value['latitude']);
      final lng = _parseDouble(value['longitude']);
      if (lat != null && lng != null) {
        return DeviceLocation(latitude: lat, longitude: lng);
      }
    }
    return null;
  }
}

