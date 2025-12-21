import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/leave_api_response_model.dart';
import '../models/leave_balance_model.dart';
import '../models/leave_model.dart';
import '../models/leave_type_model.dart';
import 'package:flutter/foundation.dart';


abstract class LeaveRemoteDataSource {
  Future<LeaveModel> createLeaveRequest({
    required int employeeId,
    required String employeeCode,
    required int departmentId,
    required int leaveTypeId,
    required DateTime startDate,
    required DateTime endDate,
    required bool isHalfDayStart,
    required bool isHalfDayEnd,
    required String reason,
    String? supportingDocumentUrl,
    Map<String, dynamic>? metadata,
  });

  Future<List<LeaveModel>> getLeaveRecords({
    int? employeeId,
    String? status,
    int? leaveTypeId,
    String? startDate,
    String? endDate,
    int? departmentId,
  });

  Future<LeaveModel> getLeaveRecordById({
    required int leaveId,
  });

  Future<LeaveModel> updateLeaveRequest({
    required int leaveId,
    required int employeeId,
    required String employeeCode,
    required int departmentId,
    required int leaveTypeId,
    required DateTime startDate,
    required DateTime endDate,
    required bool isHalfDayStart,
    required bool isHalfDayEnd,
    required String reason,
    String? supportingDocumentUrl,
    Map<String, dynamic>? metadata,
  });

  Future<List<LeaveBalanceModel>> getLeaveBalance();

  Future<LeaveModel> cancelLeaveRequest({
    required int leaveId,
    required String cancellationReason,
  });

  Future<List<LeaveTypeModel>> getLeaveTypes();
}

class LeaveRemoteDataSourceImpl implements LeaveRemoteDataSource {
  final Dio dio;

  LeaveRemoteDataSourceImpl({required this.dio});

  @override
  Future<LeaveModel> createLeaveRequest({
    required int employeeId,
    required String employeeCode,
    required int departmentId,
    required int leaveTypeId,
    required DateTime startDate,
    required DateTime endDate,
    required bool isHalfDayStart,
    required bool isHalfDayEnd,
    required String reason,
    String? supportingDocumentUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await dio.post(
        '/leave/leave-records',
        data: {
          'employee_id': employeeId,
          'employee_code': employeeCode,
          'department_id': departmentId,
          'leave_type_id': leaveTypeId,
          'start_date': startDate.toIso8601String().split('T')[0],
          'end_date': endDate.toIso8601String().split('T')[0],
          'is_half_day_start': isHalfDayStart,
          'is_half_day_end': isHalfDayEnd,
          'reason': reason,
          if (supportingDocumentUrl != null)
            'supporting_document_url': supportingDocumentUrl,
          'metadata': metadata ?? {},
        },
      );

      final apiResponse = LeaveApiResponseModel.fromJson(
        response.data,
        (data) => LeaveModel.fromJson(data as Map<String, dynamic>),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (apiResponse.data == null) {
          throw const ServerException('Leave request data is null');
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
  Future<List<LeaveModel>> getLeaveRecords({
    int? employeeId,
    String? status,
    int? leaveTypeId,
    String? startDate,
    String? endDate,
    int? departmentId,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        if (employeeId != null) 'employee_id': employeeId,
        if (status != null) 'status': status,
        if (leaveTypeId != null) 'leave_type_id': leaveTypeId,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
        if (departmentId != null) 'department_id': departmentId,
      };

      final response = await dio.get(
        '/leave/leave-records/me',
        queryParameters: queryParameters,
      );

      final apiResponse = LeaveApiResponseModel.fromJson(
        response.data,
        (data) => (data as List)
            .map((item) => LeaveModel.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

      if (response.statusCode == 200) {
        if (apiResponse.data == null) {
          throw const ServerException('Leave records data is null');
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
  Future<LeaveModel> getLeaveRecordById({
    required int leaveId,
  }) async {
    try {
      
      final response = await dio.get('/leave/leave-records/$leaveId');

      final apiResponse = LeaveApiResponseModel.fromJson(
        response.data,
        (data) => LeaveModel.fromJson(data as Map<String, dynamic>),
      );

      if (response.statusCode == 200) {
        if (apiResponse.data == null) {
          throw const ServerException('Leave record data is null');
        }
        return apiResponse.data!;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(apiResponse.message);
      } else if (response.statusCode == 404) {
        throw const ServerException('Leave record not found');
      } else {
        throw ServerException(apiResponse.message);
      }
    } on DioException catch (e) {
      debugPrint(' DioException: ${e.message}');
      debugPrint(' Response: ${e.response?.data}');
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException('No internet connection');
      } else if (e.response != null) {
        if (e.response?.statusCode == 404) {
          throw const ServerException('Leave record not found');
        }
        throw ServerException(
          e.response?.data['message'] ?? 'Server error occurred',
        );
      } else {
        throw const ServerException('Failed to connect to server');
      }
    } catch (e) {
      debugPrint(' Unexpected error: $e');
      if (e is UnauthorizedException ||
          e is ServerException ||
          e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<LeaveModel> updateLeaveRequest({
    required int leaveId,
    required int employeeId,
    required String employeeCode,
    required int departmentId,
    required int leaveTypeId,
    required DateTime startDate,
    required DateTime endDate,
    required bool isHalfDayStart,
    required bool isHalfDayEnd,
    required String reason,
    String? supportingDocumentUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      debugPrint('🔄 Updating leave request $leaveId');
      debugPrint('Request body: ${{
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate.toIso8601String().split('T')[0],
        'is_half_day_start': isHalfDayStart,
        'is_half_day_end': isHalfDayEnd,
        'reason': reason,
        'supporting_document_url': supportingDocumentUrl,
        'metadata': metadata,
      }}');

      final response = await dio.put(
        '/leave/leave-records/$leaveId',
        data: {
          'start_date': startDate.toIso8601String().split('T')[0],
          'end_date': endDate.toIso8601String().split('T')[0],
          'is_half_day_start': isHalfDayStart,
          'is_half_day_end': isHalfDayEnd,
          'reason': reason,
          if (supportingDocumentUrl != null && supportingDocumentUrl.isNotEmpty)
            'supporting_document_url': supportingDocumentUrl,
          'metadata': metadata ?? {},
        },
      );

      debugPrint(' Update response status: ${response.statusCode}');
      debugPrint('📥 Response data: ${response.data}');

      final apiResponse = LeaveApiResponseModel.fromJson(
        response.data,
        (data) => LeaveModel.fromJson(data as Map<String, dynamic>),
      );

      if (response.statusCode == 200) {
        if (apiResponse.data == null) {
          throw const ServerException('Leave request data is null');
        }
        return apiResponse.data!;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(apiResponse.message);
      } else {
        throw ServerException(apiResponse.message);
      }
    } on DioException catch (e) {
      debugPrint(' DioException: ${e.message}');
      debugPrint(' Response: ${e.response?.data}');
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
      debugPrint(' Unexpected error: $e');
      if (e is UnauthorizedException ||
          e is ServerException ||
          e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<List<LeaveBalanceModel>> getLeaveBalance() async {
    try {
      final response =
          await dio.get('/leave/leave-balances/me');

      final apiResponse = LeaveApiResponseModel.fromJson(
        response.data,
        (data) => (data as List)
            .map((item) =>
                LeaveBalanceModel.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

      if (response.statusCode == 200) {
        if (apiResponse.data == null) {
          throw const ServerException('Leave balance data is null');
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
  Future<LeaveModel> cancelLeaveRequest({
    required int leaveId,
    required String cancellationReason,
  }) async {
    try {
      debugPrint('🔄 Cancelling leave request $leaveId');
      debugPrint('Request body: ${{
        'cancellation_reason': cancellationReason,
        'cancelled_by': '',
      }}');

      final response = await dio.post(
        '/leave/leave-records/$leaveId/cancel',
        data: {
          'cancellation_reason': cancellationReason,
          'cancelled_by': 5,
        },
      );

      debugPrint(' Cancel response status: ${response.statusCode}');
      debugPrint('📥 Response data: ${response.data}');

      if (response.statusCode == 200) {
        // Handle the case where data might be a list or a single object
        final responseData = response.data;
        final data = responseData['data'];
        
        if (data == null) {
          throw const ServerException('Leave request data is null');
        }

        // If data is a list, take the first item; otherwise use it directly
        final leaveData = data is List 
            ? (data.isNotEmpty ? data[0] as Map<String, dynamic> : null)
            : data as Map<String, dynamic>;

        if (leaveData == null) {
          throw const ServerException('Leave request data is empty');
        }

        return LeaveModel.fromJson(leaveData);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(
          response.data['message'] ?? 'Unauthorized',
        );
      } else {
        throw ServerException(
          response.data['message'] ?? 'Server error occurred',
        );
      }
    } on DioException catch (e) {
      debugPrint(' DioException: ${e.message}');
      debugPrint(' Response: ${e.response?.data}');
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
      debugPrint(' Unexpected error: $e');
      if (e is UnauthorizedException ||
          e is ServerException ||
          e is NetworkException) {
        rethrow;
      }
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<List<LeaveTypeModel>> getLeaveTypes() async {
    try {
      final response = await dio.get('/leave/leave-types');

      final apiResponse = LeaveApiResponseModel.fromJson(
        response.data,
        (data) => (data as List)
            .map((item) =>
                LeaveTypeModel.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

      if (response.statusCode == 200) {
        if (apiResponse.data == null) {
          throw const ServerException('Leave types data is null');
        }
        // Filter to only return ACTIVE leave types
        final activeLeaveTypes = apiResponse.data!
            .where((leaveType) => leaveType.status.toUpperCase() == 'ACTIVE')
            .toList();
        return activeLeaveTypes;
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
