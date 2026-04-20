import 'package:make_my_ride/features/ride/domain/entities/vehcle_entity.dart';
import 'package:make_my_ride/shared/models/location_model.dart';

class RideEntity {
  final String id;
  final String userId;
  final String? driverId;

  final double pickupLat;
  final double pickupLng;

  final double dropLat;
  final double dropLng;

  final double distanceKm;
  final double durationMin;
  final VehicleType vehicleType;
  final double price;
  final List<LocationPoint> routePoints;

  final String status;
  final DateTime createdAt;

  RideEntity({
    required this.id,
    required this.userId,
    this.driverId,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropLat,
    required this.dropLng,
    required this.distanceKm,
    required this.durationMin,
    required this.vehicleType,
    required this.price,
    required this.routePoints,
    required this.status,
    required this.createdAt,
  });
}
