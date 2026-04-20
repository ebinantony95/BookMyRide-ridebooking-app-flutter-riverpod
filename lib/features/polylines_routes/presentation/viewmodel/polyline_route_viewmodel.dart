import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_my_ride/features/pending_rides/domain/ride_status.dart';
import 'package:make_my_ride/features/polylines_routes/domain/entities/polyline_route_entity.dart';
import 'package:make_my_ride/features/polylines_routes/domain/usecases/fetch_polyline_route.dart';
import 'package:make_my_ride/features/ride/domain/entities/ride_entitiy.dart';
import 'package:make_my_ride/shared/models/location_model.dart';

import 'polyline_route_state.dart';

class PolylineRouteViewModel extends StateNotifier<PolylineRouteState> {
  final FetchPolylineRoute fetchPolylineRoute;

  PolylineRouteViewModel(this.fetchPolylineRoute)
      : super(PolylineRouteState.initial());

  Future<void> fetchPreviewRoute({
    required LocationPoint pickup,
    required LocationPoint drop,
  }) async {
    state = state.copyWith(
      clearRoute: true,
      isLoading: true,
      clearError: true,
      clearActiveRideId: true,
    );

    try {
      final route = await fetchPolylineRoute(
        pickupLat: pickup.latitude,
        pickupLng: pickup.longitude,
        dropLat: drop.latitude,
        dropLng: drop.longitude,
      );

      state = state.copyWith(
        route: route,
        isLoading: false,
        clearError: true,
        clearActiveRideId: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        clearRoute: true,
        error: error.toString().replaceFirst('Exception: ', ''),
        clearActiveRideId: true,
      );
    }
  }

  Future<void> syncWithRide(RideEntity? ride) async {
    if (ride == null || !RideStatusValues.isActive(ride.status)) {
      clearRoute();
      return;
    }

    if (state.activeRideId == ride.id && state.hasRoute) {
      return;
    }

    if (ride.routePoints.length >= 2) {
      state = state.copyWith(
        route: PolylineRouteEntity(
          points: List<LocationPoint>.unmodifiable(ride.routePoints),
          distanceKm: ride.distanceKm,
          durationMin: ride.durationMin,
        ),
        isLoading: false,
        clearError: true,
        activeRideId: ride.id,
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      activeRideId: ride.id,
    );

    try {
      final route = await fetchPolylineRoute(
        pickupLat: ride.pickupLat,
        pickupLng: ride.pickupLng,
        dropLat: ride.dropLat,
        dropLng: ride.dropLng,
      );

      state = state.copyWith(
        route: route,
        isLoading: false,
        clearError: true,
        activeRideId: ride.id,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        clearRoute: true,
        error: error.toString().replaceFirst('Exception: ', ''),
        activeRideId: ride.id,
      );
    }
  }

  void clearPreviewRoute() {
    if (state.hasActiveRideRoute) {
      return;
    }

    clearRoute();
  }

  void clearRoute() {
    state = PolylineRouteState.initial();
  }
}
