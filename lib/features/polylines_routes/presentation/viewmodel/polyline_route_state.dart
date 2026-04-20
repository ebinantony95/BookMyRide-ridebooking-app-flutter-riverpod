import 'package:make_my_ride/features/polylines_routes/domain/entities/polyline_route_entity.dart';

class PolylineRouteState {
  final PolylineRouteEntity? route;
  final bool isLoading;
  final String? error;
  final String? activeRideId;

  const PolylineRouteState({
    this.route,
    this.isLoading = false,
    this.error,
    this.activeRideId,
  });

  factory PolylineRouteState.initial() => const PolylineRouteState();

  bool get hasRoute => route?.hasPoints ?? false;
  bool get hasActiveRideRoute => activeRideId != null && hasRoute;

  PolylineRouteState copyWith({
    PolylineRouteEntity? route,
    bool clearRoute = false,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? activeRideId,
    bool clearActiveRideId = false,
  }) {
    return PolylineRouteState(
      route: clearRoute ? null : (route ?? this.route),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      activeRideId:
          clearActiveRideId ? null : (activeRideId ?? this.activeRideId),
    );
  }
}
