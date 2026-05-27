import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/providers/sensor_providers.dart';

/// Filter chips for date range and energy/power metric on the history screen.
class FilterChips extends ConsumerWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(dateRangeFilterProvider);
    final metricFilter = ref.watch(historyMetricFilterProvider);

    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: DateRangeFilter.values.map((filter) {
                final isSelected = filter == selectedFilter;
                final label = switch (filter) {
                  DateRangeFilter.today => AppStrings.today,
                  DateRangeFilter.last7Days => AppStrings.last7Days,
                  DateRangeFilter.last30Days => AppStrings.last30Days,
                };

                return Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.sm),
                  child: ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (_) {
                      ref
                          .read(dateRangeFilterProvider.notifier)
                          .setFilter(filter);
                    },
                    backgroundColor: AppColors.surfaceDark,
                    selectedColor: AppColors.cardBgElevated,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusFull),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.inputBorder
                            : AppColors.divider,
                      ),
                    ),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.md,
                      vertical: AppDimensions.xs,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.sm),
        _MetricFilterChip(
          label: metricFilter == HistoryMetricFilter.energy
              ? AppStrings.energyFilter
              : AppStrings.powerFilter,
          onEnergy: () => ref
              .read(historyMetricFilterProvider.notifier)
              .setFilter(HistoryMetricFilter.energy),
          onPower: () => ref
              .read(historyMetricFilterProvider.notifier)
              .setFilter(HistoryMetricFilter.power),
        ),
      ],
    );
  }
}

class _MetricFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onEnergy;
  final VoidCallback onPower;

  const _MetricFilterChip({
    required this.label,
    required this.onEnergy,
    required this.onPower,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<HistoryMetricFilter>(
      offset: const Offset(0, 40),
      color: AppColors.cardBgElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        side: const BorderSide(color: AppColors.divider),
      ),
      onSelected: (value) {
        switch (value) {
          case HistoryMetricFilter.energy:
            onEnergy();
          case HistoryMetricFilter.power:
            onPower();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: HistoryMetricFilter.energy,
          child: Text(
            AppStrings.energyFilter,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
          ),
        ),
        PopupMenuItem(
          value: HistoryMetricFilter.power,
          child: Text(
            AppStrings.powerFilter,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.xs + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.cardBgElevated,
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list_rounded,
              size: 14,
              color: AppColors.textMuted.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    fontSize: 11,
                  ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.arrow_drop_down_rounded,
              size: 16,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
