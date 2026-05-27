import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/user_meter.dart';
import '../../../data/providers/meters_providers.dart';
import '../../../routing/app_router.dart';
import 'add_meter_sheet.dart';

class MeterChipRow extends ConsumerWidget {
  const MeterChipRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metersAsync = ref.watch(userMetersProvider);
    final selectedId = ref.watch(selectedMeterDeviceIdProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        metersAsync.when(
          loading: () => const SizedBox(
            height: 40,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.gold,
                ),
              ),
            ),
          ),
          error: (_, _) => _buildRow(context, ref, [
            UserMeter.local(label: 'Home', deviceId: 'esp32_001'),
          ], selectedId),
          data: (meters) => _buildRow(context, ref, meters, selectedId),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => context.push(AppRoutes.meters),
            icon: const Icon(Icons.grid_view_rounded, size: 16),
            label: const Text('View all meters'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.gold,
              padding: const EdgeInsets.only(top: AppDimensions.xs),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(
    BuildContext context,
    WidgetRef ref,
    List<UserMeter> meters,
    String selectedId,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final meter in meters) ...[
            _MeterChip(
              meter: meter,
              isSelected: meter.deviceId == selectedId,
              onTap: () => ref
                  .read(selectedMeterDeviceIdProvider.notifier)
                  .select(meter.deviceId),
            ),
            const SizedBox(width: AppDimensions.sm),
          ],
          _AddMeterChip(
            onTap: () => showAddMeterSheet(context, ref),
          ),
        ],
      ),
    );
  }
}

class _MeterChip extends StatelessWidget {
  final UserMeter meter;
  final bool isSelected;
  final VoidCallback onTap;

  const _MeterChip({
    required this.meter,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.sm + 2,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: isSelected ? AppColors.gold : AppColors.inputBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              meter.displayLabel,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isSelected ? Colors.black : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: Colors.black.withValues(alpha: 0.7),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AddMeterChip extends StatelessWidget {
  final VoidCallback onTap;

  const _AddMeterChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.sm + 2,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, size: 18, color: AppColors.textMuted),
            const SizedBox(width: 4),
            Text(
              'Add Meter',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
