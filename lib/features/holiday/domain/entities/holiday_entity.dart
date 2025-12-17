class HolidayEntity {
  final int id;
  final String holidayName;
  final DateTime holidayDate;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const HolidayEntity({
    required this.id,
    required this.holidayName,
    required this.holidayDate,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HolidayEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
