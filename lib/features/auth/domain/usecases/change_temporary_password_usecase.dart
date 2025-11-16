import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class ChangeTemporaryPasswordUseCase
    implements UseCase<void, ChangeTemporaryPasswordParams> {
  final AuthRepository repository;

  ChangeTemporaryPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ChangeTemporaryPasswordParams params) {
    return repository.changeTemporaryPassword(
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
      confirmPassword: params.confirmPassword,
    );
  }
}

class ChangeTemporaryPasswordParams {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  ChangeTemporaryPasswordParams({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });
}
