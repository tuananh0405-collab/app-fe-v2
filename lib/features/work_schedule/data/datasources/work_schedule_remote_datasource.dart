import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/employee_shift_api_response_model.dart';
import '../models/employee_shift_model.dart';

abstract class WorkScheduleRemoteDataSource {
  Future<List<EmployeeShiftModel>> getEmployeeShifts({
    required DateTime fromDate,
    required DateTime toDate,
  });
}

class WorkScheduleRemoteDataSourceImpl
    implements WorkScheduleRemoteDataSource {
  final Dio dio;

  WorkScheduleRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<EmployeeShiftModel>> getEmployeeShifts({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      final fromDateStr = fromDate.toIso8601String().split('T')[0];
      final toDateStr = toDate.toIso8601String().split('T')[0];

      final response = await dio.get(
        '/attendance/employee-shifts/my',
        queryParameters: {
          'from_date': fromDateStr,
          'to_date': toDateStr,
        },
      );

      final apiResponse = EmployeeShiftApiResponseModel.fromJson(
        response.data,
        (data) => EmployeeShiftModel.fromJson(data as Map<String, dynamic>),
      );

      if (response.statusCode == 200) {
        if (apiResponse.data == null || apiResponse.data!.data.isEmpty) {
          return [];
        }
        return apiResponse.data!.data.cast<EmployeeShiftModel>();
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
}

