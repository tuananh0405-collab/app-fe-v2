import 'lat_lng.dart';

/// Represents a place with address information
class FFPlace {
  const FFPlace({
    this.latLng = const LatLng(0.0, 0.0),
    this.name = '',
    this.address = '',
    this.city = '',
    this.state = '',
    this.country = '',
    this.zipCode = '',
  });

  final LatLng latLng;
  final String name;
  final String address;
  final String city;
  final String state;
  final String country;
  final String zipCode;

  @override
  String toString() => 'FFPlace('
      'latLng: $latLng, '
      'name: $name, '
      'address: $address, '
      'city: $city, '
      'state: $state, '
      'country: $country, '
      'zipCode: $zipCode'
      ')';

  String toStringShort() => name.isNotEmpty ? name : address;

  Map<String, dynamic> toJson() => {
        'latLng': latLng.toJson(),
        'name': name,
        'address': address,
        'city': city,
        'state': state,
        'country': country,
        'zipCode': zipCode,
      };

  static FFPlace? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return FFPlace(
      latLng: LatLng.fromJson(json['latLng'] as Map<String, dynamic>?) ??
          const LatLng(0.0, 0.0),
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      country: json['country'] as String? ?? '',
      zipCode: json['zipCode'] as String? ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FFPlace &&
          runtimeType == other.runtimeType &&
          latLng == other.latLng &&
          name == other.name &&
          address == other.address &&
          city == other.city &&
          state == other.state &&
          country == other.country &&
          zipCode == other.zipCode;

  @override
  int get hashCode =>
      latLng.hashCode ^
      name.hashCode ^
      address.hashCode ^
      city.hashCode ^
      state.hashCode ^
      country.hashCode ^
      zipCode.hashCode;
}
