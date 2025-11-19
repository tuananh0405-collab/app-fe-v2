import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/device_session_entity.dart';

abstract class DeviceRepository {
  Future<Either<Failure, List<DeviceSessionEntity>>> getMyDevices();
}

