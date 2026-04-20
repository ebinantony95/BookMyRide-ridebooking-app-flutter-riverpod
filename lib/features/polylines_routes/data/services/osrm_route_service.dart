import 'package:dio/dio.dart';
import 'package:make_my_ride/features/polylines_routes/domain/entities/polyline_route_entity.dart';
import 'package:make_my_ride/shared/models/location_model.dart';

class OsrmRouteService {
  static const String _baseUrl = 'https://router.project-osrm.org';

  final Dio _dio;

  OsrmRouteService({Dio? dio}) : _dio = dio ?? Dio();

  Future<PolylineRouteEntity> fetchRoute({
    required double pickupLat,
    required double pickupLng,
    required double dropLat,
    required double dropLng,
  }) async {
    if (pickupLat == dropLat && pickupLng == dropLng) {
      final point = LocationPoint(
        latitude: pickupLat,
        longitude: pickupLng,
      );

      return PolylineRouteEntity(
        points: [point, point],
        distanceKm: 0,
        durationMin: 0,
      );
    }

    final routePath =
        '/route/v1/driving/$pickupLng,$pickupLat;$dropLng,$dropLat';

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl$routePath',
        queryParameters: const {
          'overview': 'simplified',
          'geometries': 'geojson',
          'steps': false,
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      final data = response.data ?? <String, dynamic>{};
      final code = data['code'] as String?;
      if (code != 'Ok') {
        throw Exception(data['message'] ?? 'OSRM could not build this route.');
      }

      final routes = data['routes'] as List?;
      if (routes == null || routes.isEmpty) {
        throw Exception('OSRM returned no routes for this destination.');
      }

      final route = Map<String, dynamic>.from(routes.first as Map);
      final geometry = Map<String, dynamic>.from(
        route['geometry'] as Map? ?? const <String, dynamic>{},
      );
      final coordinates = geometry['coordinates'] as List?;
      if (coordinates == null || coordinates.isEmpty) {
        throw Exception('OSRM returned an empty route geometry.');
      }

      final points = coordinates
          .whereType<List>()
          .where((coordinate) => coordinate.length >= 2)
          .map(
            (coordinate) => LocationPoint(
              latitude: (coordinate[1] as num).toDouble(),
              longitude: (coordinate[0] as num).toDouble(),
            ),
          )
          .toList(growable: false);

      if (points.length < 2) {
        throw Exception('OSRM returned too few points to draw a route.');
      }

      final distanceKm = ((route['distance'] as num?)?.toDouble() ?? 0) / 1000;
      final durationMin = ((route['duration'] as num?)?.toDouble() ?? 0) / 60;

      return PolylineRouteEntity(
        points: points,
        distanceKm: double.parse(distanceKm.toStringAsFixed(2)),
        durationMin: double.parse(durationMin.toStringAsFixed(1)),
      );
    } on DioException catch (error) {
      throw Exception(_mapDioError(error));
    }
  }

  String _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Route request timed out. Please try again.';
      case DioExceptionType.badResponse:
        return 'OSRM route service is unavailable right now.';
      case DioExceptionType.connectionError:
        return 'No internet connection. We could not fetch the road route.';
      default:
        return 'Failed to fetch the road route.';
    }
  }
}
