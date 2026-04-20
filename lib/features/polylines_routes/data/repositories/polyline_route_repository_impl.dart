import 'package:make_my_ride/features/polylines_routes/data/services/osrm_route_service.dart';
import 'package:make_my_ride/features/polylines_routes/domain/entities/polyline_route_entity.dart';
import 'package:make_my_ride/features/polylines_routes/domain/repositories/polyline_route_repository.dart';

class PolylineRouteRepositoryImpl implements PolylineRouteRepository {
  final OsrmRouteService _service;

  PolylineRouteRepositoryImpl(this._service);

  @override
  Future<PolylineRouteEntity> getRoute({
    required double pickupLat,
    required double pickupLng,
    required double dropLat,
    required double dropLng,
  }) {
    return _service.fetchRoute(
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      dropLat: dropLat,
      dropLng: dropLng,
    );
  }
}
