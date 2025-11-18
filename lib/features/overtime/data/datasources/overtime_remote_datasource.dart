import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/overtime_api_response_model.dart';
import '../models/overtime_model.dart';

abstract class OvertimeRemoteDataSource {
  Future<OvertimeModel> createOvertimeRequest({
    required int shiftId,
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

  Future<OvertimeModel> updateOvertimeRequest({
    required int overtimeId,
    required int shiftId,
    required DateTime overtimeDate,
    required DateTime startTime,
    required DateTime endTime,
    required double estimatedHours,
    required String reason,
  });
}

class OvertimeRemoteDataSourceImpl implements OvertimeRemoteDataSource {
  final Dio dio;

  OvertimeRemoteDataSourceImpl({required this.dio});

  @override
  Future<OvertimeModel> createOvertimeRequest({
    required int shiftId,
    required DateTime overtimeDate,
    required DateTime startTime,
    required DateTime endTime,
    required double estimatedHours,
    required String reason,
  }) async {
    try {
      final response = await dio.post(
        '/attendance/overtime-requests',
        data: {
          'shift_id': shiftId,
          'overtime_date': overtimeDate.toIso8601String().split('T')[0],
          'start_time': startTime.toIso8601String(),
          'end_time': endTime.toIso8601String(),
          'estimated_hours': estimatedHours.toString(),
          'reason': reason,
        },
      );

      final apiResponse = OvertimeApiResponseModel.fromJson(
        response.data,
        (data) => OvertimeModel.fromJson(data as Map<String, dynamic>),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
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
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          e.response?.data['message'] ?? 'Unauthorized',
        );
      }
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to create overtime request',
      );
    } catch (e) {
      throw ServerException('An unexpected error occurred: ${e.toString()}');
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
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          e.response?.data['message'] ?? 'Unauthorized',
        );
      }
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to fetch overtime requests',
      );
    } catch (e) {
      throw ServerException('An unexpected error occurred: ${e.toString()}');
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
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          e.response?.data['message'] ?? 'Unauthorized',
        );
      }
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to fetch overtime request',
      );
    } catch (e) {
      throw ServerException('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<OvertimeModel> updateOvertimeRequest({
    required int overtimeId,
    required int shiftId,
    required DateTime overtimeDate,
    required DateTime startTime,
    required DateTime endTime,
    required double estimatedHours,
    required String reason,
  }) async {
    try {
      final response = await dio.put(
        '/attendance/overtime-requests/$overtimeId',
        data: {
          'start_time': startTime.toIso8601String(),
          'end_time': endTime.toIso8601String(),
          'estimated_hours': estimatedHours.toString(),
          'reason': reason,
        },
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
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          e.response?.data['message'] ?? 'Unauthorized',
        );
      }
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to update overtime request',
      );
    } catch (e) {
      throw ServerException('An unexpected error occurred: ${e.toString()}');
    }
  }
}
