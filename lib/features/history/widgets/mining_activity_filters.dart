import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/providers/mining_providers.dart';
import '../../../data/providers/sensor_providers.dart';

/// Status and sort filters for the minting activity screen.
class MiningActivityFilters extends ConsumerWidget {
  const MiningActivityFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusFilter = ref.watch(miningStatusFilterProvider);
    final sortOrder = ref.watch(miningSortOrderProvider);
    final dateFilter = ref.watch(dateRangeFilterProvider);

    final periodLabel = switch (dateFilter) {
      DateRangeFilter.today => AppStrings.today,
      DateRangeFilter.last7Days => AppStrings.last7Days,
      DateRangeFilter.last30Days => AppStrings.last30Days,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Period: $periodLabel',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textMuted,
              ),
        ),
        const SizedBox(height: AppDimensions.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: MiningStatusFilter.values.map((filter) {
              final isSelected = filter == statusFilter;
              final label = switch (filter) {
                MiningStatusFilter.all => AppStrings.filterAll,
                MiningStatusFilter.pending => AppStrings.statusPending,
                MiningStatusFilter.confirmed => AppStrings.statusConfirmed,
              };
              return Padding(
                padding: const EdgeInsets.only(right: AppDimensions.sm),
                child: ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (_) => ref
                      .read(miningStatusFilterProvider.notifier)
                      .setFilter(filter),
                  backgroundColor: AppColors.surfaceDark,
                  selectedColor: AppColors.gold,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : AppColors.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 13,
                  ),
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                    side: BorderSide(
                      color: isSelected ? AppColors.gold : AppColors.divider,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        Align(
          alignment: Alignment.centerRight,
          child: _SortDropdown(
            sortOrder: sortOrder,
            onChanged: (order) =>
                ref.read(miningSortOrderProvider.notifier).setOrder(order),
          ),
        ),
      ],
    );
  }
}

class _SortDropdown extends StatelessWidget {
  final MiningSortOrder sortOrder;
  final ValueChanged<MiningSortOrder> onChanged;

  const _SortDropdown({
    required this.sortOrder,
    required this.onChanged,
  });

  String _label(MiningSortOrder order) => switch (order) {
        MiningSortOrder.newest => AppStrings.sortNewest,
        MiningSortOrder.oldest => AppStrings.sortOldest,
        MiningSortOrder.wattDesc => AppStrings.sortWattHigh,
        MiningSortOrder.kwhDesc => AppStrings.sortKwhHigh,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<MiningSortOrder>(
          value: sortOrder,
          dropdownColor: AppColors.cardBgElevated,
          icon: const Icon(Icons.sort_rounded, color: AppColors.gold, size: 18),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
          items: MiningSortOrder.values
              .map(
                (o) => DropdownMenuItem(
                  value: o,
                  child: Text(_label(o)),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
