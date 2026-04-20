import 'package:equatable/equatable.dart';
import 'package:make_my_ride/shared/models/location_model.dart';

class PolylineRouteEntity extends Equatable {
  final List<LocationPoint> points;
  final double distanceKm;
  final double durationMin;

  const PolylineRouteEntity({
    required this.points,
    required this.distanceKm,
    required this.durationMin,
  });

  bool get hasPoints => points.length >= 2;

  @override
  List<Object?> get props => [points, distanceKm, durationMin];
}
