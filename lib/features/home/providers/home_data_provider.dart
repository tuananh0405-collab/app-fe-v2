import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../domain/models/shift_model.dart';
import '../domain/models/location_status_model.dart';
import '../domain/gps_scan_record.dart';

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
// Stream provider that yields the latest LocationStatusModel based on the latest
// saved GPS scan in the 'gps_history' Hive box. It initially yields the last
// saved record (if any) and then yields an updated model whenever the box
// changes.
final locationStatusProvider = StreamProvider<LocationStatusModel>((ref) async* {
  try {
    if (!Hive.isBoxOpen('gps_history')) {
      await Hive.initFlutter();
      await Hive.openBox('gps_history');
    }
    final box = Hive.box('gps_history');

    LocationStatusModel mapFrom(Map<dynamic, dynamic> json) {
      final record = GpsScanRecord.fromJson(json);
      final data = record.responseData ?? {};
      final bool isInside = (data['is_inside_work_zone'] == true) || (data['isInsideWorkZone'] == true);
      final String locationName = (data['location_name'] as String?) ?? (data['locationName'] as String?) ?? '';
      double? distance;
      if (data['distance'] != null) {
        final d = data['distance'];
        if (d is num) distance = d.toDouble();
      }

      return LocationStatusModel(
        isInsideWorkZone: isInside,
        locationName: locationName,
        distance: distance ?? record.accuracy,
        lastUpdate: record.timestamp,
      );
    }

    if (box.isNotEmpty) {
      final last = box.getAt(box.length - 1) as Map<dynamic, dynamic>;
      yield mapFrom(last);
    }

    await for (final _ in box.watch()) {
      if (box.isNotEmpty) {
        final last = box.getAt(box.length - 1) as Map<dynamic, dynamic>;
        yield mapFrom(last);
      }
    }
  } catch (e) {
    // If anything fails, yield a default unknown state
    yield const LocationStatusModel(
      isInsideWorkZone: false,
      locationName: '',
      distance: null,
      lastUpdate: null,
    );
  }
});
