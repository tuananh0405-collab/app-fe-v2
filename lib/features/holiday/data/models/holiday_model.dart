import '../../domain/entities/holiday_entity.dart';

class HolidayModel extends HolidayEntity {
  const HolidayModel({
    required super.id,
    required super.holidayName,
    required super.holidayDate,
    super.description,
    super.createdAt,
    super.updatedAt,
  });

  factory HolidayModel.fromJson(Map<String, dynamic> json) {
    return HolidayModel(
      id: json['id'] as int,
      holidayName: json['holiday_name'] as String,
      holidayDate: DateTime.parse(json['holiday_date'] as String),
      description: json['description'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'holiday_name': holidayName,
      'holiday_date': holidayDate.toIso8601String().split('T')[0],
      'description': description,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
