import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/login_response_entity.dart';
import '../../data/models/login_request_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, LoginResponseEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, LoginResponseEntity>> loginWithDeviceInfo(
    LoginRequest loginRequest,
  );

  Future<Either<Failure, void>> changeTemporaryPassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });
}
