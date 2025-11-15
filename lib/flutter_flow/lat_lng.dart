import 'dart:math' show cos, sqrt, asin;

/// Represents a geographic location with latitude and longitude coordinates.
class LatLng {
  const LatLng(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  @override
  String toString() => 'LatLng(lat: $latitude, lng: $longitude)';

  /// Serializes to JSON for storage/transmission
  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };

  /// Deserializes from JSON
  static LatLng? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return LatLng(
      json['latitude'] as double,
      json['longitude'] as double,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is LatLng &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => latitude.hashCode + longitude.hashCode;

  /// Calculate distance between two points in kilometers using Haversine formula
  double distanceTo(LatLng other) {
    const earthRadius = 6371; // Earth's radius in kilometers
    final dLat = _toRadians(other.latitude - latitude);
    final dLng = _toRadians(other.longitude - longitude);
    final a = cos(_toRadians(latitude)) *
            cos(_toRadians(other.latitude)) *
            (1 - cos(dLng)) /
            2 +
        (1 - cos(dLat)) / 2;
    final c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  double _toRadians(double degree) => degree * 3.141592653589793 / 180;
}

/// Serializes a LatLng to a JSON string
String? serializeLatLng(LatLng? latLng) =>
    latLng != null ? '${latLng.latitude},${latLng.longitude}' : null;

/// Deserializes a LatLng from a JSON string
LatLng? deserializeLatLng(String? latLngStr) {
  if (latLngStr == null || latLngStr.isEmpty) {
    return null;
  }
  final parts = latLngStr.split(',');
  if (parts.length != 2) {
    return null;
  }
  return LatLng(
    double.parse(parts[0]),
    double.parse(parts[1]),
  );
}
