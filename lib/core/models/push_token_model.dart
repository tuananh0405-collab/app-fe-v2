// Simple DTOs for push token registration/unregistration and response.
// Using plain classes (no Freezed) to avoid generation issues in this repo.

enum Platform { ios, android, web }

extension PlatformX on Platform {
  String toShortString() {
    return toString().split('.').last;
  }

  static Platform fromString(String? s) {
    if (s == null) return Platform.android;
    final v = s.toLowerCase();
    switch (v) {
      case 'ios':
        return Platform.ios;
      case 'web':
        return Platform.web;
      default:
        return Platform.android;
    }
  }
}

class RegisterPushTokenDto {
  final String deviceId;
  final String token;
  final Platform platform;

  RegisterPushTokenDto({
    required this.deviceId,
    required this.token,
    required this.platform,
  });

  Map<String, dynamic> toJson() => {
        'deviceId': deviceId,
        'token': token,
        'platform': platform.toShortString(),
      };

  factory RegisterPushTokenDto.fromJson(Map<String, dynamic> json) {
    return RegisterPushTokenDto(
      deviceId: json['deviceId'] as String? ?? '',
      token: json['token'] as String? ?? '',
      platform: PlatformX.fromString(json['platform'] as String?),
    );
  }
}

class UnregisterPushTokenDto {
  final String? deviceId;
  final String? token;

  UnregisterPushTokenDto({this.deviceId, this.token});

  Map<String, dynamic> toJson() => {
        if (deviceId != null) 'deviceId': deviceId,
        if (token != null) 'token': token,
      };

  factory UnregisterPushTokenDto.fromJson(Map<String, dynamic> json) {
    return UnregisterPushTokenDto(
      deviceId: json['deviceId'] as String?,
      token: json['token'] as String?,
    );
  }
}

class PushTokenResponse {
  final int id;
  final int employeeId;
  final String deviceId;
  final String token;
  final Platform platform;
  final bool isActive;
  final DateTime? lastUsedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  PushTokenResponse({
    required this.id,
    required this.employeeId,
    required this.deviceId,
    required this.token,
    required this.platform,
    required this.isActive,
    this.lastUsedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PushTokenResponse.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
      if (v is String) return DateTime.tryParse(v) ?? DateTime.fromMillisecondsSinceEpoch(0);
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return PushTokenResponse(
      id: (json['id'] as num?)?.toInt() ?? 0,
      employeeId: (json['employeeId'] as num?)?.toInt() ?? 0,
      deviceId: json['deviceId'] as String? ?? '',
      token: json['token'] as String? ?? '',
      platform: PlatformX.fromString(json['platform'] as String?),
      isActive: json['isActive'] as bool? ?? false,
      lastUsedAt: json['lastUsedAt'] == null ? null : parseDate(json['lastUsedAt']),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'employeeId': employeeId,
        'deviceId': deviceId,
        'token': token,
        'platform': platform.toShortString(),
        'isActive': isActive,
        'lastUsedAt': lastUsedAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
