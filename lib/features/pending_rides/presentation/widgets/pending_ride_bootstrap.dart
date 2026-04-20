import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_my_ride/features/maps/presentation/providers/map_providers.dart';
import 'package:make_my_ride/features/pending_rides/domain/ride_status.dart';
import 'package:make_my_ride/features/pending_rides/presentation/providers/pending_ride_provider.dart';
import 'package:make_my_ride/features/polylines_routes/presentation/providers/polyline_route_providers.dart';

class PendingRideBootstrap extends ConsumerWidget {
  const PendingRideBootstrap({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(pendingRideSyncProvider);

    ref.listen(
      activeRideProvider,
      (previous, next) {
        next.whenData((ride) {
          ref.read(polylineRouteViewModelProvider.notifier).syncWithRide(ride);

          if (!RideStatusValues.isActive(ride?.status)) {
            return;
          }

          final mapState = ref.read(mapViewModelProvider);
          if (!mapState.isSummaryMode) {
            ref.read(mapViewModelProvider.notifier).setSummaryMode(true);
          }
        });
      },
    );

    return child;
  }
}
