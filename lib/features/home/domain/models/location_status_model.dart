class LocationStatusModel {
  final bool isInsideWorkZone;
  final String locationName;
  final double? distance; // meters
  final DateTime? lastUpdate;

  const LocationStatusModel({
    required this.isInsideWorkZone,
    required this.locationName,
    this.distance,
    this.lastUpdate,
  });

  String get statusText {
    if (isInsideWorkZone) {
      return 'You are inside work zone';
    } else if (distance != null) {
      final km = distance! / 1000;
      return 'You are ${km.toStringAsFixed(1)}km away';
    } else {
      return 'Location unknown';
    }
  }
}
