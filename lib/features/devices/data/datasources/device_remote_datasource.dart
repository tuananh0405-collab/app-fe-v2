import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/device_session_model.dart';

abstract class DeviceRemoteDataSource {
  Future<List<DeviceSessionModel>> getMyDevices();
}

class DeviceRemoteDataSourceImpl implements DeviceRemoteDataSource {
  final Dio dio;

  DeviceRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<DeviceSessionModel>> getMyDevices() async {
    try {
      final response = await dio.get(
        ApiConstants.myDevicesEndpoint,
        options: Options(
          headers: ApiConstants.defaultHeaders,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        final payload = response.data;
        final devicesJson = _extractDeviceList(payload);

        return devicesJson
            .whereType<Map<String, dynamic>>()
            .map(DeviceSessionModel.fromJson)
            .toList();
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
          _extractMessage(response.data) ?? 'Unauthorized',
        );
      } else {
        throw ServerException(
          _extractMessage(response.data) ?? 'Failed to fetch devices',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException('Connection timeout');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException('No internet connection');
      }
      throw NetworkException(e.message ?? 'Network error');
    } catch (e) {
      if (e is ServerException ||
          e is UnauthorizedException ||
          e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  List<dynamic> _extractDeviceList(dynamic payload) {
    if (payload is List) {
      return payload;
    }

    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is List) {
        return data;
      }
      if (data is Map<String, dynamic>) {
        final items = data['items'];
        if (items is List) {
          return items;
        }
      }
    }

    return const <dynamic>[];
  }

  String? _extractMessage(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      return payload['message'] as String? ??
          payload['error'] as String? ??
          payload['status'] as String?;
    }
    return null;
  }
}

