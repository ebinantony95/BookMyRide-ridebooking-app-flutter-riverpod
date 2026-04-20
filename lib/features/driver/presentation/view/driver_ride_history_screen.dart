import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:make_my_ride/core/theme/app_colors.dart';
import 'package:make_my_ride/features/driver/presentation/providers/driver_ride_providers.dart';
import 'package:make_my_ride/features/pending_rides/domain/ride_status.dart';
import 'package:make_my_ride/features/ride/domain/entities/ride_entitiy.dart';

class DriverRideHistoryScreen extends ConsumerWidget {
  const DriverRideHistoryScreen({super.key});

  double _completedEarnings(List<RideEntity> rides) {
    return rides
        .where((ride) => ride.status == RideStatusValues.completed)
        .fold(0.0, (total, ride) => total + ride.price);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ridesAsync = ref.watch(driverRideHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Ride History'),
      ),
      body: ridesAsync.when(
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
                const Text(
                  'Could not load your driver history.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString().replaceFirst('Exception: ', ''),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
        data: (rides) {
          final completedEarnings = _completedEarnings(rides);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(driverRideHistoryProvider);
              await ref.read(driverRideHistoryProvider.future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _DriverEarningsCard(
                  totalCompletedEarnings: completedEarnings,
                  totalTrips: rides.length,
                  completedTrips: rides
                      .where(
                        (ride) => ride.status == RideStatusValues.completed,
                      )
                      .length,
                ),
                const SizedBox(height: 16),
                if (rides.isEmpty)
                  const _EmptyDriverHistory()
                else
                  ...rides.map(
                    (ride) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _DriverRideHistoryCard(ride: ride),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DriverEarningsCard extends StatelessWidget {
  const _DriverEarningsCard({
    required this.totalCompletedEarnings,
    required this.totalTrips,
    required this.completedTrips,
  });

  final double totalCompletedEarnings;
  final int totalTrips;
  final int completedTrips;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Earnings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${totalCompletedEarnings.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$completedTrips completed trips out of $totalTrips accepted rides.',
            style: const TextStyle(
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverRideHistoryCard extends StatelessWidget {
  const _DriverRideHistoryCard({
    required this.ride,
  });

  final RideEntity ride;

  Color _statusColor(String status) {
    switch (status) {
      case RideStatusValues.completed:
        return AppColors.success;
      case RideStatusValues.accepted:
        return AppColors.primary;
      case RideStatusValues.cancelled:
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final createdAtLabel = DateFormat('dd MMM yyyy, hh:mm a').format(
      ride.createdAt.toLocal(),
    );
    final statusColor = _statusColor(ride.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
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
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  ride.status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
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
          Text(
            ride.vehicleType.name.toUpperCase(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _HistoryValue(
                  label: 'Amount',
                  value: '₹${ride.price.toStringAsFixed(0)}',
                ),
              ),
              Expanded(
                child: _HistoryValue(
                  label: 'Distance',
                  value: '${ride.distanceKm.toStringAsFixed(1)} km',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Ride ID: ${ride.id}',
            style: const TextStyle(
              color: Colors.black45,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryValue extends StatelessWidget {
  const _HistoryValue({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _EmptyDriverHistory extends StatelessWidget {
  const _EmptyDriverHistory();

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
            Icons.history_rounded,
            size: 52,
            color: AppColors.textHint,
          ),
          SizedBox(height: 16),
          Text(
            'No driver rides yet.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Accepted and completed rides will show up here with your earnings.',
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
