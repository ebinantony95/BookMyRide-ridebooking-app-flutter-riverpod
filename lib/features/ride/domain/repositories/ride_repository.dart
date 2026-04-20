import 'package:make_my_ride/features/ride/domain/entities/ride_entitiy.dart';

abstract class RideRepository {
  Future<void> createRide(RideEntity ride);
  Future<List<RideEntity>> getUserRides(String userId);
  Future<List<RideEntity>> getDriverRides(String driverId);
  Future<List<RideEntity>> getPendingRides();
  Future<void> updateRideStatus(String rideId, String status);
  Future<void> acceptRide({
    required String rideId,
    required String driverId,
  });
  Future<void> deleteRide(String rideId);
  Future<RideEntity?> getActiveRide(String userId);
  Future<RideEntity?> getDriverActiveRide(String driverId);
  Stream<RideEntity?> watchActiveRide(String userId);
  Stream<RideEntity?> watchDriverActiveRide(String driverId);
  Stream<RideEntity?> watchRide(String rideId);
}
