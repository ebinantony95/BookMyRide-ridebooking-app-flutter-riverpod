import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';

// ─── App Card ─────────────────────────────────────────────────────────────────
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? color;
  final List<BoxShadow>? boxShadow;
  final double? radius;
  final BorderRadius? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.boxShadow,
    this.radius,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            borderRadius ?? BorderRadius.circular(radius ?? AppRadius.md),
        child: Ink(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color ?? AppColors.cardBackground,
            borderRadius:
                borderRadius ?? BorderRadius.circular(radius ?? AppRadius.md),
            border: Border.all(color: AppColors.border, width: 0.5),
            boxShadow: boxShadow ?? AppShadows.card,
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─── Ride Card ────────────────────────────────────────────────────────────────
class RideCard extends StatelessWidget {
  final String from;
  final String to;
  final String date;
  final String fare;
  final String status;
  final VoidCallback? onTap;

  const RideCard({
    super.key,
    required this.from,
    required this.to,
    required this.date,
    required this.fare,
    required this.status,
    this.onTap,
  });

  Color get _statusColor {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.statusCompleted;
      case 'active':
      case 'ongoing':
        return AppColors.statusActive;
      case 'cancelled':
        return AppColors.statusCancelled;
      default:
        return AppColors.statusPending;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          // ─── Route indicator
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 1.5,
                height: 32,
                color: AppColors.border,
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.markerDestination,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          // ─── Route text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(from,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text(to,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // ─── Fare + status + date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(fare, style: AppTextStyles.bodySemiBold),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  status,
                  style:
                      AppTextStyles.captionBold.copyWith(color: _statusColor),
                ),
              ),
              const SizedBox(height: 4),
              Text(date, style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Driver Card ──────────────────────────────────────────────────────────────
class DriverCard extends StatelessWidget {
  final String name;
  final String vehicle;
  final String plateNumber;
  final double rating;
  final String? photoUrl;
  final String eta;
  final VoidCallback? onCallPressed;
  final VoidCallback? onMessagePressed;

  const DriverCard({
    super.key,
    required this.name,
    required this.vehicle,
    required this.plateNumber,
    required this.rating,
    required this.eta,
    this.photoUrl,
    this.onCallPressed,
    this.onMessagePressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          // ─── Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: photoUrl != null
                ? ClipOval(child: Image.network(photoUrl!, fit: BoxFit.cover))
                : const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
          ),
          const SizedBox(width: 12),
          // ─── Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.subheadingBold),
                const SizedBox(height: 2),
                Text(vehicle, style: AppTextStyles.caption),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child:
                          Text(plateNumber, style: AppTextStyles.captionBold),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.warning,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(rating.toStringAsFixed(1),
                        style: AppTextStyles.captionBold),
                  ],
                ),
              ],
            ),
          ),
          // ─── ETA + actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  'ETA $eta',
                  style: AppTextStyles.captionBold
                      .copyWith(color: AppColors.primaryDark),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _ActionButton(
                    icon: Icons.phone_rounded,
                    onTap: onCallPressed,
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.chat_bubble_rounded,
                    onTap: onMessagePressed,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ActionButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

// ─── Skeleton Loader ──────────────────────────────────────────────────────────
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.radius = AppRadius.sm,
  });

  const SkeletonLoader.circle({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        radius = AppRadius.full;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.cardBackground,
      highlightColor: AppColors.surfaceVariant,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

// ─── Ride Card Skeleton ───────────────────────────────────────────────────────
class RideCardSkeleton extends StatelessWidget {
  const RideCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Row(
        children: [
          SkeletonLoader(width: 10, height: 56, radius: AppRadius.full),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(width: double.infinity, height: 14),
                SizedBox(height: 12),
                SkeletonLoader(width: double.infinity, height: 14),
              ],
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SkeletonLoader(width: 60, height: 16),
              SizedBox(height: 6),
              SkeletonLoader(width: 72, height: 22, radius: AppRadius.full),
              SizedBox(height: 6),
              SkeletonLoader(width: 50, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTextStyles.captionBold.copyWith(color: color),
      ),
    );
  }
}
