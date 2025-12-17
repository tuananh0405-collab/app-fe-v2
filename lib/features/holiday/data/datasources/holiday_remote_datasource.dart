import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/holiday_api_response_model.dart';
import '../models/holiday_model.dart';

abstract class HolidayRemoteDataSource {
  Future<List<HolidayModel>> getHolidays({
    int limit = 100,
    int offset = 0,
  });
}

class HolidayRemoteDataSourceImpl implements HolidayRemoteDataSource {
  final Dio dio;

  HolidayRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<HolidayModel>> getHolidays({
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await dio.get(
        '/leave/holidays',
        queryParameters: {
          'year': 2025,
          'status': 'ACTIVE',
        },
      );

      if (response.statusCode == 200) {
        // Handle direct list response if applicable
        if (response.data is List) {
          return (response.data as List)
              .map((holiday) => HolidayModel.fromJson(holiday as Map<String, dynamic>))
              .toList();
        }

        final apiResponse = HolidayApiResponseModel.fromJson(
          response.data,
          (data) => data,
        );

        if (apiResponse.data == null) {
          return [];
        }

        // Handle if apiResponse.data is directly a List
        if (apiResponse.data is List) {
           return (apiResponse.data as List)
              .map((holiday) => HolidayModel.fromJson(holiday as Map<String, dynamic>))
              .toList();
        }

        // The data field contains { holidays: [...], total: number }
        final dataMap = apiResponse.data as Map<String, dynamic>;
        final holidaysList = (dataMap['holidays'] ?? dataMap['data']) as List<dynamic>;

        return holidaysList
            .map((holiday) => HolidayModel.fromJson(holiday as Map<String, dynamic>))
            .toList();
      } else if (response.statusCode == 401) {
        final apiResponse = HolidayApiResponseModel.fromJson(
          response.data,
          (data) => data,
        );
        throw UnauthorizedException(apiResponse.message);
      } else {
        final apiResponse = HolidayApiResponseModel.fromJson(
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
}
