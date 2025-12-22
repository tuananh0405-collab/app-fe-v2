import 'package:dio/dio.dart';
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
      final response = await dio.get('/auth/me');

      final apiResponse = ApiResponseModel.fromJson(
        response.data,
            (data) => ProfileModel.fromJson(data as Map<String, dynamic>),
      );

      if (response.statusCode != 200) {
        if (response.statusCode == 401) {
          throw UnauthorizedException(apiResponse.message);
        }
        throw ServerException(apiResponse.message);
      }

      final me = apiResponse.data;
      if (me == null) {
        throw const ServerException('Profile data is null');
      }

      final empId = me.employeeId;
      if (empId == null || empId.trim().isEmpty) {
        return me;
      }

      final empRes = await dio.get('/employee/employees/$empId');

      final empPayload = empRes.data;
      final empData = (empPayload is Map<String, dynamic>) ? empPayload['data'] : null;

      if (empData is! Map<String, dynamic>) {
        return me;
      }

      final deptMap = empData['department'];
      final posMap = empData['position'];

      final departmentName =
      (deptMap is Map) ? deptMap['department_name']?.toString() : null;

      final positionName =
      (posMap is Map) ? posMap['position_name']?.toString() : null;

      final departmentId = empData['department_id']?.toString();
      final positionId = empData['position_id']?.toString();

      final phone = empData['phone_number']?.toString();
      final dobStr = empData['date_of_birth']?.toString();
      final dob = dobStr != null ? DateTime.tryParse(dobStr) : null;

      final address = empData['address'];
      final addrMap = address is Map ? Map<String, dynamic>.from(address) : null;

      return me.copyWith(
        departmentId: departmentId,
        departmentName: departmentName,
        positionId: positionId,
        positionName: positionName,
        phone: phone,
        dateOfBirth: dob,
        address: addrMap,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException('No internet connection');
      } else if (e.response != null) {
        final data = e.response?.data;
        String message = 'Server error occurred';
        if (data is Map && data['message'] != null) {
          message = data['message'].toString();
        }
        throw ServerException(message);
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
