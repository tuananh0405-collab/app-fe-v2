class OvertimeApiResponseModel<T> {
  final int statusCode;
  final String message;
  final T? data;

  OvertimeApiResponseModel({
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory OvertimeApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return OvertimeApiResponseModel<T>(
      statusCode: (json['statusCode'] as num).toInt(),
      message: json['message'] as String,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
    );
  }
}
