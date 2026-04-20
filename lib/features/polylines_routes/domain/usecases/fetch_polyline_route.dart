import 'package:make_my_ride/features/polylines_routes/domain/entities/polyline_route_entity.dart';
import 'package:make_my_ride/features/polylines_routes/domain/repositories/polyline_route_repository.dart';

class FetchPolylineRoute {
  final PolylineRouteRepository repository;

  FetchPolylineRoute(this.repository);

  Future<PolylineRouteEntity> call({
    required double pickupLat,
    required double pickupLng,
    required double dropLat,
    required double dropLng,
  }) {
    return repository.getRoute(
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      dropLat: dropLat,
      dropLng: dropLng,
    );
  }
}
