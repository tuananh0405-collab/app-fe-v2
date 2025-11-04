import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:typed_data';
import '../../../../core/error/exceptions.dart';
import '../models/faceid_response_model.dart';

abstract class FaceIdRemoteDataSource {
  Future<FaceIdResponseModel> registerFaceId({
    required Uint8List embedding,
    required String userId,
  });

  Future<FaceIdResponseModel> updateFaceId({
    required Uint8List embedding,
    required String userId,
  });

  Future<FaceIdResponseModel> verifyFaceId({
    required Uint8List embedding,
    required String userId,
    required String requestId,
    double? threshold,
  });
}

class FaceIdRemoteDataSourceImpl implements FaceIdRemoteDataSource {
  final Dio dio;

  FaceIdRemoteDataSourceImpl({required this.dio});

  @override
  Future<FaceIdResponseModel> registerFaceId({
    required Uint8List embedding,
    required String userId,
  }) async {
    try {
      // Create multipart form data
      final formData = FormData.fromMap({
        'embedding': MultipartFile.fromBytes(
          embedding,
          filename: 'embedding.bin',
          contentType: MediaType('application', 'octet-stream'),
        ),
        'userId': userId,
      });

      final response = await dio.post(
        '/api/faceid/register',
        data: formData,
      );

      if (response.statusCode == 200) {
        return FaceIdResponseModel.fromJson(response.data);
      } else if (response.statusCode == 400) {
        // User already has Face ID registered, try update instead
        throw const ServerException('Face ID already registered. Please use update.');
      } else {
        throw ServerException('Failed to register Face ID: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException('Authentication required');
      } else if (e.response?.statusCode == 400) {
        throw const ServerException('Face ID already registered. Please use update.');
      }
      throw ServerException(e.message ?? 'Network error');
    }
  }

  @override
  Future<FaceIdResponseModel> updateFaceId({
    required Uint8List embedding,
    required String userId,
  }) async {
    try {
      final formData = FormData.fromMap({
        'embedding': MultipartFile.fromBytes(
          embedding,
          filename: 'embedding.bin',
          contentType: MediaType('application', 'octet-stream'),
        ),
        'userId': userId,
      });

      final response = await dio.put(
        '/api/faceid/update',
        data: formData,
      );

      if (response.statusCode == 200) {
        return FaceIdResponseModel.fromJson(response.data);
      } else {
        throw ServerException('Failed to update Face ID: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException('Authentication required');
      }
      throw ServerException(e.message ?? 'Network error');
    }
  }

  @override
  Future<FaceIdResponseModel> verifyFaceId({
    required Uint8List embedding,
    required String userId,
    required String requestId,
    double? threshold,
  }) async {
    try {
      final formData = FormData.fromMap({
        'embedding': MultipartFile.fromBytes(
          embedding,
          filename: 'embedding.bin',
          contentType: MediaType('application', 'octet-stream'),
        ),
        'userId': userId,
        if (threshold != null) 'threshold': threshold.toString(),
      });

      final response = await dio.post(
        '/api/faceid/verify/$requestId',
        data: formData,
      );

      if (response.statusCode == 200) {
        return FaceIdResponseModel.fromJson(response.data);
      } else if (response.statusCode == 410) {
        throw const ServerException('Verification window expired');
      } else {
        throw ServerException('Failed to verify Face ID: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const UnauthorizedException('Authentication required');
      } else if (e.response?.statusCode == 410) {
        throw const ServerException('Verification window expired');
      }
      throw ServerException(e.message ?? 'Network error');
    }
  }
}
