import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/shift_model.dart';
import '../domain/models/location_status_model.dart';

final currentShiftProvider = Provider<ShiftModel>((ref) {
  final now = DateTime.now();
  return ShiftModel(
    id: 'shift-1',
    name: 'Morning Shift',
    startTime: DateTime(now.year, now.month, now.day, 10, 0),
    endTime: DateTime(now.year, now.month, now.day, 12, 0),
    dayOfWeek: 'Saturday',
    status: ShiftStatus.inProgress,
  );
});

final locationStatusProvider = Provider<LocationStatusModel>((ref) {
  return const LocationStatusModel(
    isInsideWorkZone: true,
    locationName: 'Main Office',
    distance: 0,
    lastUpdate: null,
  );
});
