import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:make_my_ride/features/pending_rides/data/models/ride_model.dart';
import 'package:make_my_ride/features/pending_rides/domain/ride_status.dart';
import 'package:make_my_ride/features/ride/domain/entities/ride_entitiy.dart';

class RideRemoteDatasource {
  final FirebaseFirestore firestore;

  RideRemoteDatasource(this.firestore);

  CollectionReference<Map<String, dynamic>> get _ridesCollection =>
      firestore.collection('rides');

  Query<Map<String, dynamic>> _userRidesQuery(String userId) {
    return _ridesCollection.where('userId', isEqualTo: userId);
  }

  Query<Map<String, dynamic>> _driverRidesQuery(String driverId) {
    return _ridesCollection.where('driverId', isEqualTo: driverId);
  }

  Query<Map<String, dynamic>> _pendingRidesQuery() {
    return _ridesCollection.where(
      'status',
      isEqualTo: RideStatusValues.pending,
    );
  }

  RideEntity? _extractActiveRide(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final rides = docs
        .map((doc) => RideModel.fromFirestore(doc).toEntity())
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    for (final ride in rides) {
      if (RideStatusValues.isActive(ride.status)) {
        return ride;
      }
    }

    return null;
  }

  Future<void> createRide(RideEntity ride) async {
    final rideModel = RideModel.fromEntity(ride);
    await _ridesCollection.doc(ride.id).set(
          rideModel.toFirestore(),
        );
  }

  Future<List<RideEntity>> getUserRides(String userId) async {
    final snapshot = await _userRidesQuery(userId).get();

    final rides = snapshot.docs
        .map((doc) => RideModel.fromFirestore(doc).toEntity())
        .toList();
    rides.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return rides;
  }

  Future<List<RideEntity>> getDriverRides(String driverId) async {
    final snapshot = await _driverRidesQuery(driverId).get();

    final rides = snapshot.docs
        .map((doc) => RideModel.fromFirestore(doc).toEntity())
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return rides;
  }

  Future<List<RideEntity>> getPendingRides() async {
    final snapshot = await _pendingRidesQuery().get();
    final rides = snapshot.docs
        .map((doc) => RideModel.fromFirestore(doc).toEntity())
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return rides;
  }

  Future<void> updateRideStatus(String rideId, String status) async {
    await _ridesCollection.doc(rideId).update({
      'status': status,
    });
  }

  Future<void> acceptRide({
    required String rideId,
    required String driverId,
  }) async {
    final rideRef = _ridesCollection.doc(rideId);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(rideRef);

      if (!snapshot.exists) {
        throw Exception('This ride is no longer available.');
      }

      final ride = RideModel.fromFirestore(snapshot).toEntity();
      if (ride.status != RideStatusValues.pending) {
        throw Exception('This ride has already been accepted.');
      }

      transaction.update(rideRef, {
        'status': RideStatusValues.accepted,
        'driverId': driverId,
      });
    });
  }

  Future<void> deleteRide(String rideId) async {
    await _ridesCollection.doc(rideId).delete();
  }

  Future<RideEntity?> getActiveRide(String userId) async {
    final snapshot = await _userRidesQuery(userId).get();
    return _extractActiveRide(snapshot.docs);
  }

  Future<RideEntity?> getDriverActiveRide(String driverId) async {
    final snapshot = await _driverRidesQuery(driverId).get();
    return _extractActiveRide(snapshot.docs);
  }

  Stream<RideEntity?> watchActiveRide(String userId) {
    return _userRidesQuery(userId).snapshots().map(
          (snapshot) => _extractActiveRide(snapshot.docs),
        );
  }

  Stream<RideEntity?> watchDriverActiveRide(String driverId) {
    return _driverRidesQuery(driverId).snapshots().map(
          (snapshot) => _extractActiveRide(snapshot.docs),
        );
  }

  Stream<RideEntity?> watchRide(String rideId) {
    return _ridesCollection.doc(rideId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }

      return RideModel.fromFirestore(snapshot).toEntity();
    });
  }
}
