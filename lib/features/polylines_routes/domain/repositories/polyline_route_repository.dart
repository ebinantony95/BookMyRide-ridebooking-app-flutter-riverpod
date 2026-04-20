import 'package:make_my_ride/features/polylines_routes/domain/entities/polyline_route_entity.dart';

abstract class PolylineRouteRepository {
  Future<PolylineRouteEntity> getRoute({
    required double pickupLat,
    required double pickupLng,
    required double dropLat,
    required double dropLng,
  });
}
