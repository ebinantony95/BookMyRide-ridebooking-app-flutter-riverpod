import 'package:make_my_ride/features/pending_rides/domain/ride_status.dart';
import 'package:make_my_ride/features/ride/domain/entities/ride_entitiy.dart';
import 'package:make_my_ride/features/ride/domain/entities/vehcle_entity.dart';
import 'package:make_my_ride/shared/models/location_model.dart';
import 'package:uuid/uuid.dart';

import 'calculate_distance.dart';
import 'calculate_price.dart';

class CreateRide {
  final CalculateDistance distanceCalc;
  final CalculatePrice priceCalc;

  static const maxDistance = 150;

  CreateRide(this.distanceCalc, this.priceCalc);

  RideEntity call({
    required String userId,
    required double pickupLat,
    required double pickupLng,
    required double dropLat,
    required double dropLng,
    required VehicleType vehicle,
    required List<LocationPoint> routePoints,
    required double distanceKm,
    required double durationMin,
  }) {
    final fallbackDistance =
        distanceCalc(pickupLat, pickupLng, dropLat, dropLng);
    final distance = distanceKm > 0 ? distanceKm : fallbackDistance;

    if (distance > maxDistance) {
      throw Exception("Distance > 150km not allowed");
    }

    final price = priceCalc(distance, vehicle);

    return RideEntity(
      id: const Uuid().v4(),
      userId: userId,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      dropLat: dropLat,
      dropLng: dropLng,
      distanceKm: distance,
      durationMin: durationMin,
      vehicleType: vehicle,
      price: price,
      routePoints: List<LocationPoint>.unmodifiable(routePoints),
      status: RideStatusValues.pending,
      createdAt: DateTime.now().toUtc(),
    );
  }
}
