import '../../domain/entities/device_session_entity.dart';

enum DeviceListStatus { initial, loading, loaded, refreshing, error }

class DeviceListState {
  final DeviceListStatus status;
  final List<DeviceSessionEntity> devices;
  final String? errorMessage;
  final DateTime? lastUpdated;

  const DeviceListState({
    this.status = DeviceListStatus.initial,
    this.devices = const [],
    this.errorMessage,
    this.lastUpdated,
  });

  bool get isLoading => status == DeviceListStatus.loading;
  bool get isRefreshing => status == DeviceListStatus.refreshing;
  bool get isLoaded => status == DeviceListStatus.loaded;
  bool get hasError => status == DeviceListStatus.error;
  bool get isEmpty => devices.isEmpty;

  DeviceListState copyWith({
    DeviceListStatus? status,
    List<DeviceSessionEntity>? devices,
    String? errorMessage,
    bool clearError = false,
    DateTime? lastUpdated,
  }) {
    return DeviceListState(
      status: status ?? this.status,
      devices: devices ?? this.devices,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

