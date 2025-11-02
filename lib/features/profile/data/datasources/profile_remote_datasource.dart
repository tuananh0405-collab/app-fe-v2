import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../auth/data/models/api_response_model.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl({required this.dio});

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}/auth/me',
        options: Options(
          headers: ApiConstants.defaultHeaders,
          validateStatus: (status) => status! < 500,
        ),
      );

      final apiResponse = ApiResponseModel.fromJson(
        response.data,
        (data) => ProfileModel.fromJson(data as Map<String, dynamic>),
      );

      if (response.statusCode == 200) {
        if (apiResponse.data == null) {
          throw const ServerException('Profile data is null');
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
}
