import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:make_my_ride/core/router/app_routes.dart';
import 'package:make_my_ride/core/theme/app_colors.dart';
import 'package:make_my_ride/features/auth/presentation/providers/auth_provider.dart';
import 'package:make_my_ride/features/driver/presentation/providers/driver_ride_providers.dart';
import 'package:make_my_ride/features/ride/domain/entities/ride_entitiy.dart';
import 'package:make_my_ride/features/ride/presentation/providers/ride_provider.dart';

class DriverHome extends ConsumerStatefulWidget {
  const DriverHome({super.key});

  @override
  ConsumerState<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends ConsumerState<DriverHome> {
  String? _acceptingRideId;

  Future<void> _refreshPendingRides() async {
    ref.invalidate(driverPendingRidesProvider);
    await ref.read(driverPendingRidesProvider.future);
  }

  Future<void> _acceptRide(RideEntity ride, RideEntity? activeRide) async {
    final driverId = ref.read(driverUserIdProvider);
    if (driverId == null || driverId.isEmpty) {
      return;
    }

    if (activeRide != null && activeRide.id != ride.id) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Complete your current trip before accepting another ride.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _acceptingRideId = ride.id;
    });

    try {
      await ref.read(rideRepositoryProvider).acceptRide(
            rideId: ride.id,
            driverId: driverId,
          );

      ref.invalidate(driverPendingRidesProvider);

      if (!mounted) {
        return;
      }

      context.push('${AppRoutes.driverRide}/${ride.id}');
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
          _acceptingRideId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final pendingRidesAsync = ref.watch(driverPendingRidesProvider);
    final activeRideAsync = ref.watch(driverActiveRideProvider);
    final activeRide = activeRideAsync.valueOrNull;
    final driverName = authState.user?.name?.trim();

    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person_outline,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      driverName != null && driverName.isNotEmpty
                          ? driverName
                          : 'Driver Account',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authState.user?.phoneNumber ?? 'Signed-in driver',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.history_rounded),
                title: const Text('Ride History'),
                subtitle: const Text('See taken rides and your earnings'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.push(AppRoutes.driverRideHistory);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.logout_rounded, color: AppColors.error),
                title: const Text('Sign Out'),
                subtitle: const Text('Exit this driver account'),
                onTap: () {
                  Navigator.of(context).pop();
                  ref.read(authViewModelProvider.notifier).signOut();
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(
          driverName != null && driverName.isNotEmpty
              ? 'Driver Home • $driverName'
              : 'Driver Home',
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPendingRides,
        child: pendingRidesAsync.when(
          loading: () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: const [
              SizedBox(height: 180),
              Center(child: CircularProgressIndicator()),
            ],
          ),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 120),
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Could not load pending rides.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  error.toString().replaceFirst('Exception: ', ''),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
            ],
          ),
          data: (pendingRides) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                if (activeRide != null) ...[
                  _ActiveTripCard(
                    ride: activeRide,
                    onOpenTrip: () {
                      context.push('${AppRoutes.driverRide}/${activeRide.id}');
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  'Pending Rides',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  activeRide != null
                      ? 'You already have an active trip. Pending rides stay visible, but you must complete the active trip first.'
                      : 'Pull down to refresh and accept a pending ride.',
                  style: const TextStyle(
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                if (pendingRides.isEmpty)
                  const _EmptyPendingRides()
                else
                  ...pendingRides.map(
                    (ride) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PendingRideCard(
                        ride: ride,
                        isAccepting: _acceptingRideId == ride.id,
                        hasActiveRide: activeRide != null,
                        onAccept: () => _acceptRide(ride, activeRide),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ActiveTripCard extends StatelessWidget {
  const _ActiveTripCard({
    required this.ride,
    required this.onOpenTrip,
  });

  final RideEntity ride;
  final VoidCallback onOpenTrip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Active Trip',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ride ${ride.id.substring(0, 8).toUpperCase()} is accepted and ready to complete.',
            style: const TextStyle(
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricChip(
                icon: Icons.electric_rickshaw_rounded,
                label: ride.vehicleType.name.toUpperCase(),
              ),
              _MetricChip(
                icon: Icons.straighten_rounded,
                label: '${ride.distanceKm.toStringAsFixed(1)} km',
              ),
              _MetricChip(
                icon: Icons.currency_rupee_rounded,
                label: ride.price.toStringAsFixed(0),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onOpenTrip,
              child: const Text('Open Active Trip'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingRideCard extends StatelessWidget {
  const _PendingRideCard({
    required this.ride,
    required this.isAccepting,
    required this.hasActiveRide,
    required this.onAccept,
  });

  final RideEntity ride;
  final bool isAccepting;
  final bool hasActiveRide;
  final VoidCallback onAccept;

  String _formatLocation(double lat, double lng) {
    return '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
  }

  @override
  Widget build(BuildContext context) {
    final createdAtLabel = DateFormat('dd MMM, hh:mm a').format(
      ride.createdAt.toLocal(),
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'PENDING',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                createdAtLabel,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Pickup',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatLocation(ride.pickupLat, ride.pickupLng),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Destination',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatLocation(ride.dropLat, ride.dropLng),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricChip(
                icon: Icons.electric_rickshaw_rounded,
                label: ride.vehicleType.name.toUpperCase(),
              ),
              _MetricChip(
                icon: Icons.straighten_rounded,
                label: '${ride.distanceKm.toStringAsFixed(1)} km',
              ),
              _MetricChip(
                icon: Icons.currency_rupee_rounded,
                label: ride.price.toStringAsFixed(0),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isAccepting || hasActiveRide ? null : onAccept,
              icon: isAccepting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline_rounded),
              label: Text(
                isAccepting
                    ? 'Accepting Ride...'
                    : hasActiveRide
                        ? 'Finish Active Ride First'
                        : 'Accept Ride',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPendingRides extends StatelessWidget {
  const _EmptyPendingRides();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 52,
            color: AppColors.textHint,
          ),
          SizedBox(height: 16),
          Text(
            'No pending rides right now.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Pull to refresh and check again when a rider creates a new trip.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
