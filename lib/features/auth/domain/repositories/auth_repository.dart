import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/login_response_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, LoginResponseEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> changeTemporaryPassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });
}
