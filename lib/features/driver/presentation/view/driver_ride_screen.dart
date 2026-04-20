import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:make_my_ride/core/theme/app_colors.dart';
import 'package:make_my_ride/features/driver/presentation/providers/driver_ride_providers.dart';
import 'package:make_my_ride/features/pending_rides/domain/ride_status.dart';
import 'package:make_my_ride/features/ride/domain/entities/ride_entitiy.dart';
import 'package:make_my_ride/features/ride/presentation/providers/ride_provider.dart';

class DriverRideScreen extends ConsumerStatefulWidget {
  const DriverRideScreen({
    super.key,
    required this.rideId,
  });

  final String rideId;

  @override
  ConsumerState<DriverRideScreen> createState() => _DriverRideScreenState();
}

class _DriverRideScreenState extends ConsumerState<DriverRideScreen> {
  final MapController _mapController = MapController();
  bool _isCompleting = false;
  bool _isMapReady = false;
  String? _lastFitSignature;
  RideEntity? _pendingFitRide;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  String _fitSignature(RideEntity ride) {
    return [
      ride.id,
      ride.pickupLat,
      ride.pickupLng,
      ride.dropLat,
      ride.dropLng,
      ride.routePoints.length,
    ].join(':');
  }

  void _handleMapReady() {
    if (_isMapReady || !mounted) {
      return;
    }

    _isMapReady = true;

    final pendingRide = _pendingFitRide;
    _pendingFitRide = null;
    if (pendingRide != null) {
      _fitRide(pendingRide);
      return;
    }

    final ride = ref.read(driverRideByIdProvider(widget.rideId)).valueOrNull;
    if (ride != null) {
      _fitRide(ride);
    }
  }

  void _fitRide(RideEntity ride) {
    if (!_isMapReady) {
      _pendingFitRide = ride;
      return;
    }

    final routePoints = ride.routePoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList(growable: false);
    final mapPoints = routePoints.isNotEmpty
        ? routePoints
        : <LatLng>[
            LatLng(ride.pickupLat, ride.pickupLng),
            LatLng(ride.dropLat, ride.dropLng),
          ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || mapPoints.length < 2) {
        return;
      }

      _mapController.fitCamera(
        CameraFit.coordinates(
          coordinates: mapPoints,
          padding: const EdgeInsets.fromLTRB(40, 88, 40, 260),
          maxZoom: 16,
        ),
      );
    });
  }

  Future<void> _completeRide(RideEntity ride) async {
    setState(() {
      _isCompleting = true;
    });

    try {
      await ref.read(rideRepositoryProvider).updateRideStatus(
            ride.id,
            RideStatusValues.completed,
          );

      ref.invalidate(driverPendingRidesProvider);

      if (!mounted) {
        return;
      }

      context.pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideAsync = ref.watch(driverRideByIdProvider(widget.rideId));
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen(driverRideByIdProvider(widget.rideId), (previous, next) {
      next.whenData((ride) {
        if (ride == null) {
          return;
        }

        final signature = _fitSignature(ride);
        if (signature == _lastFitSignature) {
          return;
        }

        _lastFitSignature = signature;
        _fitRide(ride);
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Trip'),
      ),
      body: rideAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: 12),
                Text(
                  error.toString().replaceFirst('Exception: ', ''),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        data: (ride) {
          if (ride == null) {
            return const Center(
              child: Text('This ride is no longer available.'),
            );
          }

          final routePoints = ride.routePoints
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList(growable: false);
          final pickupPoint = LatLng(ride.pickupLat, ride.pickupLng);
          final destinationPoint = LatLng(ride.dropLat, ride.dropLng);
          final isCompleted = ride.status == RideStatusValues.completed;

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: pickupPoint,
                  initialZoom: 14,
                  onMapReady: _handleMapReady,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.make_my_ride',
                  ),
                  if (routePoints.length >= 2)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: routePoints,
                          strokeWidth: 5,
                          color: AppColors.primary,
                          borderStrokeWidth: 2,
                          borderColor:
                              colorScheme.surface.withValues(alpha: 0.88),
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: pickupPoint,
                        child: Icon(
                          Icons.radio_button_checked,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                      ),
                      Marker(
                        point: destinationPoint,
                        child: Icon(
                          Icons.location_pin,
                          color: AppColors.textPrimary,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 24,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowMedium,
                        blurRadius: 20,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Trip Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _TripDetailRow(
                        label: 'Pickup',
                        value:
                            '${ride.pickupLat.toStringAsFixed(5)}, ${ride.pickupLng.toStringAsFixed(5)}',
                      ),
                      const SizedBox(height: 10),
                      _TripDetailRow(
                        label: 'Destination',
                        value:
                            '${ride.dropLat.toStringAsFixed(5)}, ${ride.dropLng.toStringAsFixed(5)}',
                      ),
                      const SizedBox(height: 10),
                      _TripDetailRow(
                        label: 'Distance',
                        value: '${ride.distanceKm.toStringAsFixed(1)} km',
                      ),
                      const SizedBox(height: 10),
                      _TripDetailRow(
                        label: 'Fare',
                        value: '₹${ride.price.toStringAsFixed(0)}',
                      ),
                      const SizedBox(height: 10),
                      _TripDetailRow(
                        label: 'Status',
                        value: ride.status.toUpperCase(),
                        valueColor:
                            isCompleted ? AppColors.info : AppColors.success,
                      ),
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: isCompleted || _isCompleting
                            ? null
                            : () => _completeRide(ride),
                        child: _isCompleting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Complete'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TripDetailRow extends StatelessWidget {
  const _TripDetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
