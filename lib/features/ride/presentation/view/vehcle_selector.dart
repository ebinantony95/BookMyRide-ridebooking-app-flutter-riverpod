import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_my_ride/core/theme/theme.dart';
import 'package:make_my_ride/features/ride/domain/entities/vehcle_entity.dart';
import 'package:make_my_ride/features/ride/presentation/providers/ride_provider.dart';

class VehicleSelector extends ConsumerWidget {
  const VehicleSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedVehicle =
        ref.watch(rideViewModelProvider.select((s) => s.selectedVehicle));

    return Row(
      children: [
        Expanded(
          child: _VehicleCard(
            ref: ref,
            label: "Bike",
            type: VehicleType.bike,
            icon: Icons.pedal_bike,
            isSelected: selectedVehicle == VehicleType.bike,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _VehicleCard(
            ref: ref,
            label: "Auto",
            type: VehicleType.auto,
            icon: Icons.electric_rickshaw,
            isSelected: selectedVehicle == VehicleType.auto,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _VehicleCard(
            ref: ref,
            label: "Car",
            type: VehicleType.car,
            icon: Icons.directions_car,
            isSelected: selectedVehicle == VehicleType.car,
          ),
        ),
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final WidgetRef ref;
  final String label;
  final VehicleType type;
  final IconData icon;
  final bool isSelected;

  const _VehicleCard({
    required this.ref,
    required this.label,
    required this.type,
    required this.icon,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        ref.read(rideViewModelProvider.notifier).selectVehicle(type);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.onSurface : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colorScheme.onSurface : AppColors.border,
            width: 2,
          ),
          boxShadow: isSelected ? AppShadows.card : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? colorScheme.surface : AppColors.textPrimary,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? colorScheme.surface : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
