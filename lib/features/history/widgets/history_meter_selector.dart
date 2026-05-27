import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/user_meter.dart';
import '../../../data/providers/meters_providers.dart';

/// Selected meter name with tap-to-change sheet (replaces chip row).
class HistoryMeterSelector extends ConsumerWidget {
  const HistoryMeterSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metersAsync = ref.watch(userMetersProvider);
    final selectedId = ref.watch(selectedMeterDeviceIdProvider);

    return metersAsync.when(
      loading: () => const SizedBox(
        height: 32,
        child: Align(
          alignment: Alignment.centerLeft,
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
      error: (_, _) => _MeterNameButton(
        label: 'Home',
        onTap: () => _showMeterSheet(
          context,
          ref,
          [UserMeter.local(label: 'Home', deviceId: 'esp32_001')],
          selectedId,
        ),
      ),
      data: (meters) {
        final selected = meters
            .where((m) => m.deviceId == selectedId)
            .firstOrNull;
        final label = selected?.label ?? selectedId;

        return _MeterNameButton(
          label: label,
          onTap: () => _showMeterSheet(context, ref, meters, selectedId),
        );
      },
    );
  }

  void _showMeterSheet(
    BuildContext context,
    WidgetRef ref,
    List<UserMeter> meters,
    String selectedId,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLg),
        ),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.md,
                  ),
                  child: Text(
                    AppStrings.selectMeter,
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),
                ...meters.map((meter) {
                  final isSelected = meter.deviceId == selectedId;
                  return ListTile(
                    leading: Icon(
                      Icons.electric_meter_rounded,
                      color: isSelected ? AppColors.gold : AppColors.textMuted,
                    ),
                    title: Text(
                      meter.label,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.gold
                            : AppColors.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      meter.deviceId,
                      style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_rounded, color: AppColors.gold)
                        : null,
                    onTap: () {
                      ref
                          .read(selectedMeterDeviceIdProvider.notifier)
                          .select(meter.deviceId);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MeterNameButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _MeterNameButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(width: AppDimensions.xs),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
            size: 28,
          ),
        ],
      ),
    );
  }
}
