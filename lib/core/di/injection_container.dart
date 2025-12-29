import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import '../constants/api_constants.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/change_temporary_password_usecase.dart';
import '../../features/auth/domain/usecases/change_password_usecase.dart';
import '../network/network_info.dart';
import '../services/gps_tracking_service.dart';
import '../services/push_notification_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ========== Features - Auth ==========

  // UseCases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => ChangeTemporaryPasswordUseCase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // DataSources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );

  // ========== Core ==========
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  
  // Services
  sl.registerLazySingleton(() => GpsTrackingService(sl()));
  sl.registerLazySingleton(
    () => PushNotificationService(
      gpsTrackingService: sl(),
    ),
  );

  // ========== External ==========
  sl.registerLazySingleton(
    () => Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15), // Reduced from 30s
        receiveTimeout: const Duration(seconds: 15), // Reduced from 30s
        sendTimeout: const Duration(seconds: 15), // Reduced from 30s
        headers: ApiConstants.defaultHeaders,
        validateStatus: (status) => status != null && status < 500,
      ),
    ),
  );
  sl.registerLazySingleton(() => InternetConnectionChecker());
}
