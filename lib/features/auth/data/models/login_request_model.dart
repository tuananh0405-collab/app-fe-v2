class LoginRequest {
  final String email;
  final String password;
  final String deviceId;
  final String deviceName;
  final String deviceOs;
  final String deviceModel;
  final String platform;
  final String appVersion;
  final LocationData? location;
  final String? fcmToken;

  const LoginRequest({
    required this.email,
    required this.password,
    required this.deviceId,
    required this.deviceName,
    required this.deviceOs,
    required this.deviceModel,
    required this.platform,
    required this.appVersion,
    this.location,
    this.fcmToken,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'device_id': deviceId,
        'device_name': deviceName,
        'device_os': deviceOs,
        'device_model': deviceModel,
        'platform': platform,
        'app_version': appVersion,
        if (location != null) 'location': location!.toJson(),
        if (fcmToken != null) 'fcm_token': fcmToken,
      };
}

class LocationData {
  final double latitude;
  final double longitude;

  const LocationData({
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}