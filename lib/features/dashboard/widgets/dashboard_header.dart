import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/providers/sensor_providers.dart';
import '../../../routing/app_router.dart';

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(meterConnectivityProvider);
    final (statusColor, statusLabel) = switch (connectivity) {
      MeterConnectivity.live => (AppColors.online, AppStrings.statusLive),
      MeterConnectivity.stale => (AppColors.warning, AppStrings.statusNotLive),
      MeterConnectivity.none => (AppColors.offline, AppStrings.statusOffline),
    };

    return Row(
      children: [
        const Icon(Icons.bolt_rounded, color: AppColors.gold, size: 28),
        const SizedBox(width: AppDimensions.sm),
        Text(
          'WATT',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.gold,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.md,
            vertical: AppDimensions.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Text(
                statusLabel,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.sm),
        GestureDetector(
          onTap: () => context.go(AppRoutes.settings),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.cardBgElevated,
            child: const Icon(
              Icons.person_outline,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}
