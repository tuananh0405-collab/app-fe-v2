enum DevicePlatform {
  web('WEB', 'Web'),
  android('ANDROID', 'Android'),
  ios('IOS', 'iOS'),
  mac('MAC', 'macOS'),
  windows('WINDOWS', 'Windows'),
  linux('LINUX', 'Linux'),
  other('OTHER', 'Other');

  final String value;
  final String label;

  const DevicePlatform(this.value, this.label);

  static DevicePlatform fromValue(String? value) {
    if (value == null) {
      return DevicePlatform.other;
    }
    final normalized = value.toUpperCase();
    return DevicePlatform.values.firstWhere(
      (platform) => platform.value == normalized,
      orElse: () => DevicePlatform.other,
    );
  }
}

enum DeviceStatus {
  active('ACTIVE', 'Active'),
  revoked('REVOKED', 'Revoked'),
  inactive('INACTIVE', 'Inactive'),
  expired('EXPIRED', 'Expired'),
  other('OTHER', 'Other');

  final String value;
  final String label;

  const DeviceStatus(this.value, this.label);

  static DeviceStatus fromValue(String? value) {
    if (value == null) {
      return DeviceStatus.other;
    }
    final normalized = value.toUpperCase();
    return DeviceStatus.values.firstWhere(
      (status) => status.value == normalized,
      orElse: () => DeviceStatus.other,
    );
  }
}

enum FcmTokenStatus {
  active('ACTIVE', 'Active'),
  inactive('INACTIVE', 'Inactive'),
  revoked('REVOKED', 'Revoked'),
  other('OTHER', 'Other');

  final String value;
  final String label;

  const FcmTokenStatus(this.value, this.label);

  static FcmTokenStatus fromValue(String? value) {
    if (value == null) {
      return FcmTokenStatus.other;
    }
    final normalized = value.toUpperCase();
    return FcmTokenStatus.values.firstWhere(
      (status) => status.value == normalized,
      orElse: () => FcmTokenStatus.other,
    );
  }
}

class DeviceLocation {
  final double latitude;
  final double longitude;

  const DeviceLocation({
    required this.latitude,
    required this.longitude,
  });
}

class DeviceSessionEntity {
  final int id;
  final int accountId;
  final int? employeeId;
  final String deviceId;
  final String? deviceName;
  final String? deviceOs;
  final String? deviceModel;
  final String? deviceFingerprint;
  final DevicePlatform platform;
  final String? appVersion;
  final bool isTrusted;
  final DateTime? trustedAt;
  final int? trustedBy;
  final String? trustVerificationMethod;
  final DateTime firstLoginAt;
  final DateTime? lastLoginAt;
  final DateTime? lastActiveAt;
  final int loginCount;
  final int failedLoginAttempts;
  final DateTime? lastFailedAt;
  final String? lastIpAddress;
  final DeviceLocation? lastLocation;
  final String? lastUserAgent;
  final String? networkType;
  final String? fcmToken;
  final DateTime? fcmTokenUpdatedAt;
  final FcmTokenStatus fcmTokenStatus;
  final DeviceStatus status;
  final DateTime? revokedAt;
  final int? revokedBy;
  final String? revokeReason;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DeviceSessionEntity({
    required this.id,
    required this.accountId,
    this.employeeId,
    required this.deviceId,
    this.deviceName,
    this.deviceOs,
    this.deviceModel,
    this.deviceFingerprint,
    required this.platform,
    this.appVersion,
    this.isTrusted = false,
    this.trustedAt,
    this.trustedBy,
    this.trustVerificationMethod,
    required this.firstLoginAt,
    this.lastLoginAt,
    this.lastActiveAt,
    this.loginCount = 0,
    this.failedLoginAttempts = 0,
    this.lastFailedAt,
    this.lastIpAddress,
    this.lastLocation,
    this.lastUserAgent,
    this.networkType,
    this.fcmToken,
    this.fcmTokenUpdatedAt,
    this.fcmTokenStatus = FcmTokenStatus.other,
    this.status = DeviceStatus.other,
    this.revokedAt,
    this.revokedBy,
    this.revokeReason,
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
  });

  DeviceSessionEntity copyWith({
    int? id,
    int? accountId,
    int? employeeId,
    String? deviceId,
    String? deviceName,
    String? deviceOs,
    String? deviceModel,
    String? deviceFingerprint,
    DevicePlatform? platform,
    String? appVersion,
    bool? isTrusted,
    DateTime? trustedAt,
    int? trustedBy,
    String? trustVerificationMethod,
    DateTime? firstLoginAt,
    DateTime? lastLoginAt,
    DateTime? lastActiveAt,
    int? loginCount,
    int? failedLoginAttempts,
    DateTime? lastFailedAt,
    String? lastIpAddress,
    DeviceLocation? lastLocation,
    String? lastUserAgent,
    String? networkType,
    String? fcmToken,
    DateTime? fcmTokenUpdatedAt,
    FcmTokenStatus? fcmTokenStatus,
    DeviceStatus? status,
    DateTime? revokedAt,
    int? revokedBy,
    String? revokeReason,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeviceSessionEntity(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      employeeId: employeeId ?? this.employeeId,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      deviceOs: deviceOs ?? this.deviceOs,
      deviceModel: deviceModel ?? this.deviceModel,
      deviceFingerprint: deviceFingerprint ?? this.deviceFingerprint,
      platform: platform ?? this.platform,
      appVersion: appVersion ?? this.appVersion,
      isTrusted: isTrusted ?? this.isTrusted,
      trustedAt: trustedAt ?? this.trustedAt,
      trustedBy: trustedBy ?? this.trustedBy,
      trustVerificationMethod:
          trustVerificationMethod ?? this.trustVerificationMethod,
      firstLoginAt: firstLoginAt ?? this.firstLoginAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      loginCount: loginCount ?? this.loginCount,
      failedLoginAttempts: failedLoginAttempts ?? this.failedLoginAttempts,
      lastFailedAt: lastFailedAt ?? this.lastFailedAt,
      lastIpAddress: lastIpAddress ?? this.lastIpAddress,
      lastLocation: lastLocation ?? this.lastLocation,
      lastUserAgent: lastUserAgent ?? this.lastUserAgent,
      networkType: networkType ?? this.networkType,
      fcmToken: fcmToken ?? this.fcmToken,
      fcmTokenUpdatedAt: fcmTokenUpdatedAt ?? this.fcmTokenUpdatedAt,
      fcmTokenStatus: fcmTokenStatus ?? this.fcmTokenStatus,
      status: status ?? this.status,
      revokedAt: revokedAt ?? this.revokedAt,
      revokedBy: revokedBy ?? this.revokedBy,
      revokeReason: revokeReason ?? this.revokeReason,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

