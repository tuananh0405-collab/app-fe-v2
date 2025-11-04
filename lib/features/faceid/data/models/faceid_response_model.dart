class FaceIdResponseModel {
  final bool success;
  final String message;
  final dynamic data;

  const FaceIdResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory FaceIdResponseModel.fromJson(Map<String, dynamic> json) {
    return FaceIdResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
    };
  }
}
