import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:make_my_ride/features/ride/domain/entities/ride_entitiy.dart';
import 'package:make_my_ride/features/ride/domain/entities/vehcle_entity.dart';
import 'package:make_my_ride/shared/models/location_model.dart';

class RideModel extends RideEntity {
  RideModel({
    required super.id,
    required super.userId,
    super.driverId,
    required super.pickupLat,
    required super.pickupLng,
    required super.dropLat,
    required super.dropLng,
    required super.distanceKm,
    required super.durationMin,
    required super.vehicleType,
    required super.price,
    required super.routePoints,
    required super.status,
    required super.createdAt,
  });

  factory RideModel.fromEntity(RideEntity entity) {
    return RideModel(
      id: entity.id,
      userId: entity.userId,
      driverId: entity.driverId,
      pickupLat: entity.pickupLat,
      pickupLng: entity.pickupLng,
      dropLat: entity.dropLat,
      dropLng: entity.dropLng,
      distanceKm: entity.distanceKm,
      durationMin: entity.durationMin,
      vehicleType: entity.vehicleType,
      price: entity.price,
      routePoints: entity.routePoints,
      status: entity.status,
      createdAt: entity.createdAt,
    );
  }

  factory RideModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};

    return RideModel(
      id: (data['id'] as String?) ?? doc.id,
      userId: data['userId'] as String? ?? '',
      driverId: data['driverId'] as String?,
      pickupLat: _asDouble(data['pickupLat']),
      pickupLng: _asDouble(data['pickupLng']),
      dropLat: _asDouble(data['dropLat']),
      dropLng: _asDouble(data['dropLng']),
      distanceKm: _asDouble(data['distanceKm']),
      durationMin: _asDouble(data['durationMin']),
      vehicleType: _vehicleTypeFromName(data['vehicleType'] as String?),
      price: _asDouble(data['price']),
      routePoints: _routePointsFromFirestore(data['routePoints']),
      status: data['status'] as String? ?? '',
      createdAt: _dateTimeFromFirestore(data['createdAt']),
    );
  }

  RideEntity toEntity() {
    return RideEntity(
      id: id,
      userId: userId,
      driverId: driverId,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      dropLat: dropLat,
      dropLng: dropLng,
      distanceKm: distanceKm,
      durationMin: durationMin,
      vehicleType: vehicleType,
      price: price,
      routePoints: routePoints,
      status: status,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'driverId': driverId,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'dropLat': dropLat,
      'dropLng': dropLng,
      'distanceKm': distanceKm,
      'durationMin': durationMin,
      'vehicleType': vehicleType.name,
      'price': price,
      'routePoints': routePoints.map((point) => point.toJson()).toList(),
      'status': status,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  static double _asDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }

    return 0;
  }

  static VehicleType _vehicleTypeFromName(String? value) {
    return VehicleType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => VehicleType.auto,
    );
  }

  static List<LocationPoint> _routePointsFromFirestore(Object? value) {
    if (value is! List) {
      return const [];
    }

    return value
        .whereType<Map>()
        .map(
          (point) => LocationPoint.fromJson(
            Map<String, dynamic>.from(point),
          ),
        )
        .toList(growable: false);
  }

  static DateTime _dateTimeFromFirestore(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value)?.toUtc() ?? DateTime.now().toUtc();
    }

    return DateTime.now().toUtc();
  }
}
