class ShiftModel {
  final String id;
  final String name;
  final DateTime startTime;
  final DateTime endTime;
  final String dayOfWeek;
  final ShiftStatus status;

  const ShiftModel({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.dayOfWeek,
    required this.status,
  });

  String get timeRange {
    final start = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final end = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }
}

enum ShiftStatus {
  upcoming,
  inProgress,
  completed,
}
