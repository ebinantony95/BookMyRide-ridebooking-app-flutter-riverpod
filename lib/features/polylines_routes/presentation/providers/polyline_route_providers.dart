import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_my_ride/features/polylines_routes/data/repositories/polyline_route_repository_impl.dart';
import 'package:make_my_ride/features/polylines_routes/data/services/osrm_route_service.dart';
import 'package:make_my_ride/features/polylines_routes/domain/repositories/polyline_route_repository.dart';
import 'package:make_my_ride/features/polylines_routes/domain/usecases/fetch_polyline_route.dart';
import 'package:make_my_ride/features/polylines_routes/presentation/viewmodel/polyline_route_state.dart';
import 'package:make_my_ride/features/polylines_routes/presentation/viewmodel/polyline_route_viewmodel.dart';

final osrmRouteServiceProvider = Provider<OsrmRouteService>(
  (ref) => OsrmRouteService(),
);

final polylineRouteRepositoryProvider = Provider<PolylineRouteRepository>(
  (ref) => PolylineRouteRepositoryImpl(ref.read(osrmRouteServiceProvider)),
);

final fetchPolylineRouteProvider = Provider<FetchPolylineRoute>(
  (ref) => FetchPolylineRoute(ref.read(polylineRouteRepositoryProvider)),
);

final polylineRouteViewModelProvider =
    StateNotifierProvider<PolylineRouteViewModel, PolylineRouteState>(
  (ref) => PolylineRouteViewModel(ref.read(fetchPolylineRouteProvider)),
);
