import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/overtime_entity.dart';
import '../repositories/overtime_repository.dart';

class GetMyOvertimeRequestsUseCase
    implements UseCase<List<OvertimeEntity>, GetMyOvertimeRequestsParams> {
  final OvertimeRepository repository;

  GetMyOvertimeRequestsUseCase(this.repository);

  @override
  Future<Either<Failure, List<OvertimeEntity>>> call(
      GetMyOvertimeRequestsParams params) async {
    return await repository.getMyOvertimeRequests(
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetMyOvertimeRequestsParams {
  final int limit;
  final int offset;

  const GetMyOvertimeRequestsParams({
    this.limit = 20,
    this.offset = 0,
  });
}
