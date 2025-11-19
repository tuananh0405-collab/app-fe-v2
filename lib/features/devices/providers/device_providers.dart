import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../../../core/network/network_info.dart';
import '../data/datasources/device_remote_datasource.dart';
import '../data/repositories/device_repository_impl.dart';
import '../domain/repositories/device_repository.dart';
import '../domain/usecases/get_my_devices_usecase.dart';
import '../presentation/controllers/device_list_controller.dart';
import '../presentation/state/device_list_state.dart';

final deviceRemoteDataSourceProvider = Provider<DeviceRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return DeviceRemoteDataSourceImpl(dio: dio);
});

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  return DeviceRepositoryImpl(
    remoteDataSource: ref.read(deviceRemoteDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

final getMyDevicesUseCaseProvider = Provider<GetMyDevicesUseCase>((ref) {
  return GetMyDevicesUseCase(ref.read(deviceRepositoryProvider));
});

final deviceListControllerProvider =
    NotifierProvider<DeviceListController, DeviceListState>(
  () => DeviceListController(),
);
