import 'package:equatable/equatable.dart';

class LocationPoint extends Equatable {
  final double latitude;
  final double longitude;
  final String? address;
  final String? name;

  const LocationPoint({
    required this.latitude,
    required this.longitude,
    this.address,
    this.name,
  });

  @override
  List<Object?> get props => [latitude, longitude, address, name];

  LocationPoint copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? name,
  }) {
    return LocationPoint(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'name': name,
    };
  }

  factory LocationPoint.fromJson(Map<String, dynamic> json) {
    return LocationPoint(
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      address: json['address'] as String?,
      name: json['name'] as String?,
    );
  }

  static double _asDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }

    return 0;
  }
}
