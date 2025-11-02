import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/api_response_model.dart';
import '../models/login_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      // Login doesn't need token in header
      final response = await dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final apiResponse = ApiResponseModel.fromJson(
        response.data,
        (data) => LoginResponseModel.fromJson(data as Map<String, dynamic>),
      );

      if (response.statusCode == 200) {
        if (apiResponse.data == null) {
          throw const ServerException('Login data is null');
        }
        return apiResponse.data!;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(apiResponse.message);
      } else if (apiResponse.errorCode == 'TEMPORARY_PASSWORD_MUST_CHANGE') {
        throw TemporaryPasswordException(apiResponse.message);
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
          e is TemporaryPasswordException ||
          e is ServerException ||
          e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }
}
