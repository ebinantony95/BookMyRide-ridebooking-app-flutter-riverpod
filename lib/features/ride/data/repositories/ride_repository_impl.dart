import 'package:make_my_ride/features/ride/data/datasource/ride_remote_datasource.dart';
import 'package:make_my_ride/features/ride/domain/entities/ride_entitiy.dart';
import 'package:make_my_ride/features/ride/domain/repositories/ride_repository.dart';

class RideRepositoryImpl implements RideRepository {
  final RideRemoteDatasource remote;

  RideRepositoryImpl(this.remote);

  @override
  Future<void> createRide(RideEntity ride) {
    return remote.createRide(ride);
  }

  @override
  Future<List<RideEntity>> getUserRides(String userId) {
    return remote.getUserRides(userId);
  }

  @override
  Future<List<RideEntity>> getDriverRides(String driverId) {
    return remote.getDriverRides(driverId);
  }

  @override
  Future<List<RideEntity>> getPendingRides() {
    return remote.getPendingRides();
  }

  @override
  Future<void> updateRideStatus(String rideId, String status) {
    return remote.updateRideStatus(rideId, status);
  }

  @override
  Future<void> acceptRide({
    required String rideId,
    required String driverId,
  }) {
    return remote.acceptRide(
      rideId: rideId,
      driverId: driverId,
    );
  }

  @override
  Future<void> deleteRide(String rideId) {
    return remote.deleteRide(rideId);
  }

  @override
  Future<RideEntity?> getActiveRide(String userId) {
    return remote.getActiveRide(userId);
  }

  @override
  Future<RideEntity?> getDriverActiveRide(String driverId) {
    return remote.getDriverActiveRide(driverId);
  }

  @override
  Stream<RideEntity?> watchActiveRide(String userId) {
    return remote.watchActiveRide(userId);
  }

  @override
  Stream<RideEntity?> watchDriverActiveRide(String driverId) {
    return remote.watchDriverActiveRide(driverId);
  }

  @override
  Stream<RideEntity?> watchRide(String rideId) {
    return remote.watchRide(rideId);
  }
}
