import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/overtime_api_response_model.dart';
import '../models/overtime_model.dart';

abstract class OvertimeRemoteDataSource {
  Future<OvertimeModel> createOvertimeRequest({
    required DateTime overtimeDate,
    required DateTime startTime,
    required DateTime endTime,
    required double estimatedHours,
    required String reason,
  });

  Future<List<OvertimeModel>> getMyOvertimeRequests({
    int limit = 20,
    int offset = 0,
  });

  Future<OvertimeModel> getOvertimeRequestById({
    required int overtimeId,
  });

  Future<void> updateOvertimeRequest({
    required int overtimeId,
    required int shiftId,
    required DateTime overtimeDate,
    required DateTime startTime,
    required DateTime endTime,
    required double estimatedHours,
    required String reason,
  });
  
    Future<void> cancelOvertimeRequest({
      required int overtimeId,
    });
}

class OvertimeRemoteDataSourceImpl implements OvertimeRemoteDataSource {
  final Dio dio;
  
  // Backend automatically subtracts 7 hours from received time
  // So we need to add 7 hours before sending
  static const int TIMEZONE_OFFSET_HOURS = 0;

  OvertimeRemoteDataSourceImpl({required this.dio});

  @override
  Future<OvertimeModel> createOvertimeRequest({
    required DateTime overtimeDate,
    required DateTime startTime,
    required DateTime endTime,
    required double estimatedHours,
    required String reason,
  }) async {
    try {
      // Debug logging
      print('=== CREATE OVERTIME DEBUG ===');
      print('Input startTime: $startTime');
      print('Input endTime: $endTime');
      print('Input overtimeDate: $overtimeDate');
      
      // Backend automatically subtracts 7 hours, so we add 7 hours before sending
      final adjustedStartTime = startTime.add(Duration(hours: TIMEZONE_OFFSET_HOURS));
      final adjustedEndTime = endTime.add(Duration(hours: TIMEZONE_OFFSET_HOURS));
      
      // Format to ISO8601 with milliseconds and Z (e.g., "2025-12-28T17:45:00.000Z")
      String formatToIso8601WithZ(DateTime dt) {
        String s =  '${dt.year.toString().padLeft(4, '0')}-'
            '${dt.month.toString().padLeft(2, '0')}-'
            '${dt.day.toString().padLeft(2, '0')}T'
            '${dt.hour.toString().padLeft(2, '0')}:'
            '${dt.minute.toString().padLeft(2, '0')}:'
            '${dt.second.toString().padLeft(2, '0')}.'
            '${dt.millisecond.toString().padLeft(3, '0')}Z';

          // Use print for debug logging here; `Log` was not defined in this scope.
          print('Formatted time: $s');
          return s;
      }
      
      print('=== CREATE OVERTIME DEBUG ===');
      print('Input startTime: $startTime');
      print('Input endTime: $endTime');
      print('Adjusted startTime (+7h): $adjustedStartTime');
      print('Adjusted endTime (+7h): $adjustedEndTime');
      print('Formatted startTime: ${formatToIso8601WithZ(adjustedStartTime)}');
      print('Formatted endTime: ${formatToIso8601WithZ(adjustedEndTime)}');
      
      final payload = {
        'overtime_date': overtimeDate.toIso8601String().split('T')[0],
        'start_time': formatToIso8601WithZ(adjustedStartTime),
        'end_time': formatToIso8601WithZ(adjustedEndTime),
        'estimated_hours': estimatedHours,
        'reason': reason,
      };
      
      print('Payload: $payload');
      print('============================');
      
      final response = await dio.post(
        '/attendance/overtime-requests',
        data: payload,
      );

      final apiResponse = OvertimeApiResponseModel.fromJson(
        response.data,
        (data) => OvertimeModel.fromJson(data as Map<String, dynamic>),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (apiResponse.data == null) {
          throw ServerException('Overtime request data is null');
        }
        return apiResponse.data!;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(apiResponse.message);
      } else {
        throw ServerException(apiResponse.message);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException('No internet connection');
      } else if (e.response != null) {
        throw ServerException(
          e.response?.data['message'] ?? 'Server error occurred',
        );
      } else {
        throw const ServerException('Failed to connect to server');
      }
    } catch (e) {
      if (e is UnauthorizedException ||
          e is ServerException ||
          e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> cancelOvertimeRequest({
    required int overtimeId,
  }) async {
    try {
      final response = await dio.post(
        '/attendance/overtime-requests/$overtimeId/cancel',
      );
      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
          response.data['message'] ?? 'Unauthorized',
        );
      } else {
        throw ServerException(
          response.data['message'] ?? 'Cancel failed',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException('No internet connection');
      } else if (e.response != null) {
        throw ServerException(
          e.response?.data['message'] ?? 'Server error occurred',
        );
      } else {
        throw const ServerException('Failed to connect to server');
      }
    } catch (e) {
      if (e is UnauthorizedException ||
          e is ServerException ||
          e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<List<OvertimeModel>> getMyOvertimeRequests({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await dio.get(
        '/attendance/overtime-requests/my-requests',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.statusCode == 200) {
        final apiResponse = OvertimeApiResponseModel.fromJson(
          response.data,
          (data) => data,
        );

        if (apiResponse.data == null) {
          return [];
        }

        // The data field contains { data: [...], total: number }
        final dataMap = apiResponse.data as Map<String, dynamic>;
        final recordsList = dataMap['data'] as List<dynamic>;

        return recordsList
            .map((record) => OvertimeModel.fromJson(record as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        final apiResponse = OvertimeApiResponseModel.fromJson(
          response.data,
          (data) => data,
        );
        throw UnauthorizedException(apiResponse.message);
      } else {
        final apiResponse = OvertimeApiResponseModel.fromJson(
          response.data,
          (data) => data,
        );
        throw ServerException(apiResponse.message);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException('No internet connection');
      } else if (e.response != null) {
        throw ServerException(
          e.response?.data['message'] ?? 'Server error occurred',
        );
      } else {
        throw const ServerException('Failed to connect to server');
      }
    } catch (e) {
      if (e is UnauthorizedException ||
          e is ServerException ||
          e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<OvertimeModel> getOvertimeRequestById({
    required int overtimeId,
  }) async {
    try {
      final response = await dio.get(
        '/attendance/overtime-requests/$overtimeId',
      );

      final apiResponse = OvertimeApiResponseModel.fromJson(
        response.data,
        (data) => OvertimeModel.fromJson(data as Map<String, dynamic>),
      );

      if (response.statusCode == 200) {
        if (apiResponse.data == null) {
          throw const ServerException('Overtime request data is null');
        }
        return apiResponse.data!;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(apiResponse.message);
      } else {
        throw ServerException(apiResponse.message);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException('No internet connection');
      } else if (e.response != null) {
        throw ServerException(
          e.response?.data['message'] ?? 'Server error occurred',
        );
      } else {
        throw const ServerException('Failed to connect to server');
      }
    } catch (e) {
      if (e is UnauthorizedException ||
          e is ServerException ||
          e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> updateOvertimeRequest({
    required int overtimeId,
    required int shiftId,
    required DateTime overtimeDate,
    required DateTime startTime,
    required DateTime endTime,
    required double estimatedHours,
    required String reason,
  }) async {
    try {
      // Backend automatically subtracts 7 hours, so we add 7 hours before sending
      final adjustedStartTime = startTime.add(Duration(hours: TIMEZONE_OFFSET_HOURS));
      final adjustedEndTime = endTime.add(Duration(hours: TIMEZONE_OFFSET_HOURS));
      
      // Format to ISO8601 with milliseconds and Z
      String formatToIso8601WithZ(DateTime dt) {
        return '${dt.year.toString().padLeft(4, '0')}-'
            '${dt.month.toString().padLeft(2, '0')}-'
            '${dt.day.toString().padLeft(2, '0')}T'
            '${dt.hour.toString().padLeft(2, '0')}:'
            '${dt.minute.toString().padLeft(2, '0')}:'
            '${dt.second.toString().padLeft(2, '0')}.'
            '${dt.millisecond.toString().padLeft(3, '0')}Z';
      }
      
      final response = await dio.put(
        '/attendance/overtime-requests/$overtimeId',
        data: {
          'start_time': formatToIso8601WithZ(adjustedStartTime),
          'end_time': formatToIso8601WithZ(adjustedEndTime),
          'estimated_hours': estimatedHours,
          'reason': reason,
        },
      );

       if (response.statusCode == 200) {
        return; // Success
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
          response.data['message'] ?? 'Unauthorized',
        );
      } else {
        throw ServerException(
          response.data['message'] ?? 'Update failed',
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException('No internet connection');
      } else if (e.response != null) {
        throw ServerException(
          e.response?.data['message'] ?? 'Server error occurred',
        );
      } else {
        throw const ServerException('Failed to connect to server');
      }
    } catch (e) {
      if (e is UnauthorizedException ||
          e is ServerException ||
          e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }
}
