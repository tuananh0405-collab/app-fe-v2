import 'package:dartz/dartz.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/login_response_entity.dart';
import '../repositories/auth_repository.dart';
import '../../data/models/login_request_model.dart';

class LoginParams {
  final String email;
  final String password;

  const LoginParams({
    required this.email,
    required this.password,
  });
}

class LoginUseCase implements UseCase<LoginResponseEntity, LoginParams> {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  @override
  Future<Either<Failure, LoginResponseEntity>> call(LoginParams params) async {
    try {
      // Collect device information
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();
      final fcmToken = await FirebaseMessaging.instance.getToken();

      String deviceId = '';
      String deviceName = '';
      String deviceOs = '';
      String deviceModel = '';

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
        deviceName = androidInfo.model;
        deviceOs = 'Android ${androidInfo.version.release}';
        deviceModel = androidInfo.model;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? '';
        deviceName = iosInfo.name;
        deviceOs = 'iOS ${iosInfo.systemVersion}';
        deviceModel = iosInfo.model;
      }

      final loginRequest = LoginRequest(
        email: params.email,
        password: params.password,
        deviceId: deviceId,
        deviceName: deviceName,
        deviceOs: deviceOs,
        deviceModel: deviceModel,
        platform: Platform.isAndroid ? 'ANDROID' : 'IOS',
        appVersion: packageInfo.version,
        fcmToken: fcmToken,
        // Location can be added later if needed
      );

      return await repository.loginWithDeviceInfo(loginRequest);
    } catch (e) {
      return Left(ServerFailure('Failed to collect device info: ${e.toString()}'));
    }
  }
}
