import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_my_ride/core/theme/app_colors.dart';
import 'package:make_my_ride/features/maps/presentation/providers/map_providers.dart';
import 'package:make_my_ride/features/maps/presentation/view%20/widgets/detail_row.dart';
import 'package:make_my_ride/features/pending_rides/domain/ride_status.dart';
import 'package:make_my_ride/features/pending_rides/presentation/providers/pending_ride_provider.dart';
import 'package:make_my_ride/features/polylines_routes/presentation/providers/polyline_route_providers.dart';
import 'package:make_my_ride/features/ride/domain/usecases/calculate_price.dart';
import 'package:make_my_ride/features/ride/presentation/providers/ride_provider.dart';
import 'package:make_my_ride/features/ride/presentation/providers/user_id_provider.dart';
import 'package:make_my_ride/features/ride/presentation/view/vehcle_selector.dart';
import 'searching_ride_widget.dart';

class RideSummaryWidget extends ConsumerWidget {
  const RideSummaryWidget({super.key});

  bool _isBlockingRideStatus(String? status) {
    return RideStatusValues.isActive(status);
  }

  Future<void> _confirmAndDeleteRide(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete Ride?'),
              content: const Text(
                'This will remove the ride from Firestore and clear your active ride immediately.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!shouldDelete || !context.mounted) {
      return;
    }

    await ref.read(rideViewModelProvider.notifier).deleteCurrentRide();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rideState = ref.watch(rideViewModelProvider);
    final activeRideAsync = ref.watch(activeRideProvider);
    final mapState = ref.watch(mapViewModelProvider);
    final polylineRouteState = ref.watch(polylineRouteViewModelProvider);
    final userId = ref.watch(userIdProvider);

    final isCheckingActiveRide =
        activeRideAsync.isLoading && activeRideAsync.valueOrNull == null;
    final hasActiveRideSyncError = activeRideAsync.hasError;
    final currentRide = activeRideAsync.maybeWhen(
      data: (ride) => ride,
      orElse: () => rideState.currentRide,
    );

    final hasActiveRide =
        currentRide != null && _isBlockingRideStatus(currentRide.status);
    final isPendingRide = currentRide?.status == RideStatusValues.pending;
    final isAcceptedRide = currentRide?.status == RideStatusValues.accepted;
    final pickup = mapState.currentLocation;
    final drop = mapState.selectedPlace;
    final selectedVehicle = rideState.selectedVehicle;
    final canCreateRide =
        !hasActiveRide && !isCheckingActiveRide && !hasActiveRideSyncError;

    final routeState = polylineRouteState;
    final route = routeState.route;
    final isRouteLoading = !hasActiveRide && routeState.isLoading;
    final routeError = !hasActiveRide ? routeState.error : null;
    final hasValidRoute =
        !hasActiveRide && route != null && route.points.isNotEmpty;

    double? estimatedPrice;
    double? estimatedDuration;
    if (selectedVehicle != null && hasValidRoute) {
      estimatedPrice = CalculatePrice()(route.distanceKm, selectedVehicle);
      estimatedDuration = route.durationMin;
    }

    final isDeletingRide = rideState.isDeletingRide;
    final rideDuration = currentRide?.durationMin ?? 0;
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: rideState.isBooking
          ? const SearchingRideWidget()
          : SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                key: const ValueKey('SummaryContent'),
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          ref
                              .read(mapViewModelProvider.notifier)
                              .setSummaryMode(false);
                        },
                      ),
                      Text(
                        'Ride Summary',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (isPendingRide || isAcceptedRide)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isAcceptedRide
                            ? AppColors.successLight
                            : AppColors.warningLight,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: (isAcceptedRide
                                  ? AppColors.success
                                  : AppColors.warning)
                              .withValues(alpha: 0.35),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: (isAcceptedRide
                                          ? AppColors.success
                                          : AppColors.warning)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  isAcceptedRide
                                      ? Icons.check_circle_outline_rounded
                                      : Icons.schedule_rounded,
                                  color: isAcceptedRide
                                      ? AppColors.success
                                      : AppColors.warning,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isAcceptedRide
                                          ? 'Ride Accepted'
                                          : 'Ride Request Pending',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isAcceptedRide
                                          ? 'A driver has accepted your ride. Your next ride unlocks after this trip is completed.'
                                          : 'Waiting for a driver to accept your ride. Your next ride unlocks after this trip is completed.',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          DetailRow(
                            label: 'Vehicle',
                            value: currentRide!.vehicleType.name.toUpperCase(),
                          ),
                          const SizedBox(height: 10),
                          DetailRow(
                            label: 'Estimated Amount',
                            value: '₹${currentRide.price.toStringAsFixed(0)}',
                            emphasize: true,
                          ),
                          const SizedBox(height: 10),
                          DetailRow(
                            label: 'Distance',
                            value:
                                '${currentRide.distanceKm.toStringAsFixed(1)} km',
                          ),
                          if (rideDuration > 0) ...[
                            const SizedBox(height: 10),
                            DetailRow(
                              label: 'Estimated Time',
                              value: '${rideDuration.toStringAsFixed(0)} mins',
                            ),
                          ],
                          const SizedBox(height: 10),
                          DetailRow(
                            label: 'Status',
                            value: currentRide.status.toUpperCase(),
                            valueColor: isAcceptedRide
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                          const SizedBox(height: 20),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: isDeletingRide
                                  ? null
                                  : () => _confirmAndDeleteRide(context, ref),
                              icon: isDeletingRide
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.delete_outline_rounded),
                              label: Text(
                                isDeletingRide
                                    ? 'Deleting Ride...'
                                    : 'Delete Ride',
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: const BorderSide(
                                  color: AppColors.error,
                                  width: 1.2,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          if (rideState.error != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              rideState.error!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  else ...[
                    const VehicleSelector(),
                    const SizedBox(height: 20),
                    if (estimatedPrice != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Estimated Price',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '₹${estimatedPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (hasValidRoute) ...[
                      DetailRow(
                        label: 'Road Distance',
                        value: '${route.distanceKm.toStringAsFixed(1)} km',
                      ),
                      if (estimatedDuration != null) ...[
                        const SizedBox(height: 10),
                        DetailRow(
                          label: 'Estimated Time',
                          value: '${estimatedDuration.toStringAsFixed(0)} mins',
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],
                    if (isRouteLoading)
                      Padding(
                        padding: EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          'Drawing the road route from your current location...',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    if (routeError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          routeError,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    if (isCheckingActiveRide)
                      Padding(
                        padding: EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          'Checking whether you already have an active ride...',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    if (rideState.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          rideState.error!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: canCreateRide &&
                                hasValidRoute &&
                                !isRouteLoading
                            ? () {
                                if (selectedVehicle == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Please select a vehicle type.',
                                      ),
                                      backgroundColor:
                                          colorScheme.inverseSurface,
                                    ),
                                  );
                                  return;
                                }

                                if (pickup == null || drop == null) {
                                  return;
                                }

                                final routeToBook = route;
                                if (routeToBook.points.isEmpty) {
                                  return;
                                }

                                ref
                                    .read(rideViewModelProvider.notifier)
                                    .createRide(
                                      userId: userId,
                                      pickupLat: pickup.latitude,
                                      pickupLng: pickup.longitude,
                                      dropLat: drop.lat,
                                      dropLng: drop.lon,
                                      routePoints: routeToBook.points,
                                      distanceKm: routeToBook.distanceKm,
                                      durationMin: routeToBook.durationMin,
                                    );
                              }
                            : null,
                        child: Text(
                          hasActiveRide
                              ? 'Ride In Progress'
                              : isCheckingActiveRide
                                  ? 'Checking Active Ride...'
                                  : isRouteLoading
                                      ? 'Drawing Route...'
                                      : !hasValidRoute
                                          ? 'Route Required'
                                          : 'Book Ride',
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
