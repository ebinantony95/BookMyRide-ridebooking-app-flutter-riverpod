import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_my_ride/features/auth/presentation/providers/auth_provider.dart';
import 'package:make_my_ride/features/ride/domain/entities/ride_entitiy.dart';
import 'package:make_my_ride/features/ride/presentation/providers/ride_provider.dart';

final driverUserIdProvider = Provider<String?>((ref) {
  final user = ref.watch(authViewModelProvider).user;
  return user?.uid;
});

final driverPendingRidesProvider =
    FutureProvider.autoDispose<List<RideEntity>>((ref) async {
  final repository = ref.watch(rideRepositoryProvider);
  return repository.getPendingRides();
});

final driverRideHistoryProvider =
    FutureProvider.autoDispose<List<RideEntity>>((ref) async {
  final driverId = ref.watch(driverUserIdProvider);

  if (driverId == null || driverId.isEmpty) {
    return const [];
  }

  final repository = ref.watch(rideRepositoryProvider);
  return repository.getDriverRides(driverId);
});

final driverActiveRideProvider = StreamProvider.autoDispose<RideEntity?>((ref) {
  final driverId = ref.watch(driverUserIdProvider);

  if (driverId == null || driverId.isEmpty) {
    return Stream.value(null);
  }

  return ref.watch(rideRepositoryProvider).watchDriverActiveRide(driverId);
});

final driverRideByIdProvider =
    StreamProvider.autoDispose.family<RideEntity?, String>((ref, rideId) {
  return ref.watch(rideRepositoryProvider).watchRide(rideId);
});
