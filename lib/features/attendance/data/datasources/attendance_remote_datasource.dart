import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/attendance_model.dart';

abstract class AttendanceRemoteDataSource {
  Future<AttendanceResponseModel> getMyAttendance({
    required String startDate,
    required String endDate,
    String? status,
    int page = 1,
    int limit = 20,
  });
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final Dio dio;

  AttendanceRemoteDataSourceImpl({required this.dio});

  @override
  Future<AttendanceResponseModel> getMyAttendance({
    required String startDate,
    required String endDate,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = {
        'start_date': startDate,
        'end_date': endDate,
        'page': page,
        'limit': limit,
      };

      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await dio.get(
        '/attendance/employee-shifts/my-attendance',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        try {
          final data = response.data['data'];
          print('📊 Parsing attendance data: $data');
          return AttendanceResponseModel.fromJson(data);
        } catch (e, stackTrace) {
          print('Error parsing attendance response: $e');
          print('Stack trace: $stackTrace');
          throw ServerException('Failed to parse attendance data: ${e.toString()}');
        }
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
            response.data['message'] ?? 'Unauthorized');
      } else {
        throw ServerException(
            response.data['message'] ?? 'Failed to fetch attendance');
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
      print('Unexpected error in getMyAttendance: $e');
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }
}
