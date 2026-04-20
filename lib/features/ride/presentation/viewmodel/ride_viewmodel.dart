import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_my_ride/features/pending_rides/domain/ride_status.dart';
import 'package:make_my_ride/features/ride/domain/entities/ride_entitiy.dart';
import 'package:make_my_ride/features/ride/domain/entities/vehcle_entity.dart';
import 'package:make_my_ride/features/ride/domain/usecases/create_ride.dart';
import 'package:make_my_ride/features/ride/domain/usecases/get_user_ride.dart';
import 'package:make_my_ride/shared/models/location_model.dart';

import '../../domain/repositories/ride_repository.dart';
import 'ride_state.dart';

class RideViewModel extends StateNotifier<RideState> {
  static const _searchDuration = Duration(seconds: 10);

  final CreateRide createRideUseCase;
  final GetUserRides getUserRidesUseCase;
  final RideRepository repository;
  Timer? _searchTimer;

  RideViewModel(
    this.createRideUseCase,
    this.getUserRidesUseCase,
    this.repository,
  ) : super(RideState.initial());

  String _formatRideError(Object error, {String? prefix}) {
    final message = error.toString().replaceFirst('Exception: ', '');

    if (message.contains('[cloud_firestore/failed-precondition]')) {
      return 'Ride data needs a Firestore index before active rides can sync.';
    }

    return prefix == null ? message : '$prefix$message';
  }

  void _startSearchCountdown(String rideId) {
    _searchTimer?.cancel();
    _searchTimer = Timer(_searchDuration, () {
      final currentRide = state.currentRide;
      if (currentRide?.id == rideId &&
          currentRide?.status == RideStatusValues.pending) {
        state = state.copyWith(isBooking: false);
      }
    });
  }

  void _stopSearchCountdown() {
    _searchTimer?.cancel();
    _searchTimer = null;
  }

  void selectVehicle(VehicleType type) {
    state = state.copyWith(selectedVehicle: type);
  }

  Future<void> createRide({
    required String userId,
    required double pickupLat,
    required double pickupLng,
    required double dropLat,
    required double dropLng,
    required List<LocationPoint> routePoints,
    required double distanceKm,
    required double durationMin,
  }) async {
    try {
      // Check for active ride before creating a new one
      final activeRide = await repository.getActiveRide(userId);
      if (activeRide != null) {
        _stopSearchCountdown();
        state = state.copyWith(
          error:
              'You already have an active ride. You can create a new ride only after the current ride is completed.',
          currentRide: activeRide,
          isBooking: false,
          isDeletingRide: false,
        );
        return;
      }

      final ride = createRideUseCase(
        userId: userId,
        pickupLat: pickupLat,
        pickupLng: pickupLng,
        dropLat: dropLat,
        dropLng: dropLng,
        vehicle: state.selectedVehicle!,
        routePoints: routePoints,
        distanceKm: distanceKm,
        durationMin: durationMin,
      );

      await repository.createRide(ride);

      state = state.copyWith(
        currentRide: ride,
        isBooking: true,
        isDeletingRide: false,
        error: null,
      );
      _startSearchCountdown(ride.id);
    } catch (e) {
      _stopSearchCountdown();
      state = state.copyWith(
        error: _formatRideError(e),
        isBooking: false,
        isDeletingRide: false,
        clearCurrentRide: true,
      );
    }
  }

  void syncActiveRideState(RideEntity? activeRide) {
    final shouldKeepSearching = state.isBooking &&
        state.currentRide?.id == activeRide?.id &&
        activeRide?.status == RideStatusValues.pending;

    if (!shouldKeepSearching) {
      _stopSearchCountdown();
    }

    state = state.copyWith(
      currentRide: activeRide,
      clearCurrentRide: activeRide == null,
      isBooking: shouldKeepSearching,
      isDeletingRide: false,
      error: null,
    );
  }

  void setActiveRideSyncError(Object error) {
    _stopSearchCountdown();
    state = state.copyWith(
      error: _formatRideError(error, prefix: 'Failed to sync active ride: '),
      isBooking: false,
      isDeletingRide: false,
    );
  }

  Future<void> cancelBooking() async {
    await deleteCurrentRide();
  }

  Future<void> deleteCurrentRide() async {
    final currentRide = state.currentRide;
    _stopSearchCountdown();
    if (currentRide != null) {
      try {
        state = state.copyWith(
          isBooking: false,
          isDeletingRide: true,
          error: null,
        );
        await repository.deleteRide(currentRide.id);
        state = state.copyWith(
          isBooking: false,
          isDeletingRide: false,
          clearCurrentRide: true,
          error: null,
        );
      } catch (e) {
        state = state.copyWith(
          isDeletingRide: false,
          error: _formatRideError(e, prefix: 'Failed to delete ride: '),
        );
      }
    } else {
      state = state.copyWith(
        isBooking: false,
        isDeletingRide: false,
      );
    }
  }

  Future<void> loadHistory(String userId) async {
    final rides = await getUserRidesUseCase(userId);
    state = state.copyWith(history: rides);
  }

  @override
  void dispose() {
    _stopSearchCountdown();
    super.dispose();
  }
}
