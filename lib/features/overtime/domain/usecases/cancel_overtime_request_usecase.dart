import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/overtime_repository.dart';

class CancelOvertimeRequestUseCase {
  final OvertimeRepository repository;
  CancelOvertimeRequestUseCase(this.repository);

  Future<Either<Failure, void>> call(int overtimeId) {
    return repository.cancelOvertimeRequest(overtimeId: overtimeId);
  }
}
