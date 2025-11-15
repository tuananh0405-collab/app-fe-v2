class LeaveApiResponseModel<T> {
  final String status;
  final int statusCode;
  final String message;
  final T? data;
  final String? errorCode;
  final String? timestamp;
  final String? path;

  const LeaveApiResponseModel({
    required this.status,
    required this.statusCode,
    required this.message,
    this.data,
    this.errorCode,
    this.timestamp,
    this.path,
  });

  factory LeaveApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return LeaveApiResponseModel(
      status: json['status'] as String? ?? '',
      statusCode: json['statusCode'] as int,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      errorCode: json['errorCode'] as String?,
      timestamp: json['timestamp'] as String?,
      path: json['path'] as String?,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T)? toJsonT) {
    return {
      'status': status,
      'statusCode': statusCode,
      'message': message,
      'data': data != null && toJsonT != null ? toJsonT(data as T) : null,
      'errorCode': errorCode,
      'timestamp': timestamp,
      'path': path,
    };
  }
}
