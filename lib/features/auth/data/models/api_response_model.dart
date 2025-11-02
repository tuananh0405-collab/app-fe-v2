class ApiResponseModel<T> {
  final bool success;
  final String message;
  final T? data;
  final String? errorCode;

  const ApiResponseModel({
    required this.success,
    required this.message,
    this.data,
    this.errorCode,
  });

  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      errorCode: json['error_code'] as String?,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T)? toJsonT) {
    return {
      'success': success,
      'message': message,
      'data': data != null && toJsonT != null ? toJsonT(data as T) : null,
      'error_code': errorCode,
    };
  }
}
