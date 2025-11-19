import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_my_devices_usecase.dart';
import '../../providers/device_providers.dart';
import '../state/device_list_state.dart';

class DeviceListController extends Notifier<DeviceListState> {
  late final GetMyDevicesUseCase _getMyDevicesUseCase;

  @override
  DeviceListState build() {
    _getMyDevicesUseCase = ref.read(getMyDevicesUseCaseProvider);
    return const DeviceListState();
  }

  Future<void> loadDevices({bool refresh = false}) async {
    final nextStatus =
        refresh ? DeviceListStatus.refreshing : DeviceListStatus.loading;

    state = state.copyWith(status: nextStatus, clearError: true);

    final result = await _getMyDevicesUseCase(const NoParams());

    result.fold(
      (failure) {
        state = state.copyWith(
          status: DeviceListStatus.error,
          errorMessage: failure.message,
        );
      },
      (devices) {
        state = state.copyWith(
          status: DeviceListStatus.loaded,
          devices: devices,
          clearError: true,
          lastUpdated: DateTime.now(),
        );
      },
    );
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }
}

