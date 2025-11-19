class EmployeeShiftApiResponseModel<T> {
  final String status;
  final int statusCode;
  final String message;
  final EmployeeShiftDataWrapper<T>? data;
  final String? errorCode;
  final String? timestamp;
  final String? path;

  const EmployeeShiftApiResponseModel({
    required this.status,
    required this.statusCode,
    required this.message,
    this.data,
    this.errorCode,
    this.timestamp,
    this.path,
  });

  factory EmployeeShiftApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return EmployeeShiftApiResponseModel(
      status: json['status'] as String? ?? '',
      statusCode: json['statusCode'] as int,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? EmployeeShiftDataWrapper.fromJson(
              json['data'] as Map<String, dynamic>,
              fromJsonT,
            )
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
      'data': data != null ? data!.toJson(toJsonT) : null,
      'errorCode': errorCode,
      'timestamp': timestamp,
      'path': path,
    };
  }
}

class EmployeeShiftDataWrapper<T> {
  final List<T> data;
  final int total;

  const EmployeeShiftDataWrapper({
    required this.data,
    required this.total,
  });

  factory EmployeeShiftDataWrapper.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return EmployeeShiftDataWrapper(
      data: json['data'] != null && fromJsonT != null
          ? (json['data'] as List)
              .map((item) => fromJsonT(item))
              .toList()
          : [],
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T)? toJsonT) {
    return {
      'data': data
          .map((item) => toJsonT != null ? toJsonT(item) : item)
          .toList(),
      'total': total,
    };
  }
}

