import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/network_info.dart';
import '../data/datasources/auth_remote_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/change_temporary_password_usecase.dart';
import '../domain/usecases/change_password_usecase.dart';
import '../presentation/controllers/login_controller.dart';
import '../presentation/controllers/change_password_controller.dart';
import '../presentation/state/login_state.dart';
import '../presentation/state/change_password_state.dart';
import '../domain/usecases/forgot_password_usecase.dart';
import '../presentation/controllers/forgot_password_controller.dart';
import '../presentation/state/forgot_password_state.dart';

// Data Source Provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRemoteDataSourceImpl(dio: dio);
});

// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

// Use Case Provider
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

final changeTemporaryPasswordUseCaseProvider =
    Provider<ChangeTemporaryPasswordUseCase>((ref) {
      return ChangeTemporaryPasswordUseCase(ref.read(authRepositoryProvider));
    });

final changePasswordUseCaseProvider = Provider<ChangePasswordUseCase>((ref) {
  return ChangePasswordUseCase(ref.read(authRepositoryProvider));
});

// Login Controller Provider
final loginControllerProvider = NotifierProvider<LoginController, LoginState>(
  () => LoginController(),
);

// Change Password Controller Provider
final changePasswordControllerProvider =
    NotifierProvider<ChangePasswordController, ChangePasswordState>(
  () => ChangePasswordController(),
);

// Forgot Password Controller Provider
final forgotPasswordControllerProvider =
    NotifierProvider<ForgotPasswordController, ForgotPasswordState>(
  () => ForgotPasswordController(),
);

// Use Case Provider
final forgotPasswordUseCaseProvider = Provider<ForgotPasswordUseCase>((ref) {
  return ForgotPasswordUseCase(ref.read(authRepositoryProvider));
});
