class HolidayApiResponseModel<T> {
  final bool success;
  final String message;
  final T? data;

  const HolidayApiResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory HolidayApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return HolidayApiResponseModel(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }
}
