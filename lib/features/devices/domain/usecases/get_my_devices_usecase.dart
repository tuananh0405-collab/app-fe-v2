import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/device_session_entity.dart';
import '../repositories/device_repository.dart';

class GetMyDevicesUseCase
    implements UseCase<List<DeviceSessionEntity>, NoParams> {
  final DeviceRepository repository;

  const GetMyDevicesUseCase(this.repository);

  @override
  Future<Either<Failure, List<DeviceSessionEntity>>> call(
    NoParams params,
  ) async {
    return repository.getMyDevices();
  }
}

