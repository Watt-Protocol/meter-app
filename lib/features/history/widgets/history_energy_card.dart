import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/energy_utils.dart';
import '../../../data/models/history_stats.dart';
import '../../../data/models/sensor_reading.dart';
import '../../../data/providers/sensor_providers.dart';
import 'energy_chart.dart';

class HistoryEnergyCard extends ConsumerWidget {
  final HistoryStats stats;
  final List<SensorReading> readings;
  final DateRangeFilter filter;

  const HistoryEnergyCard({
    super.key,
    required this.stats,
    required this.readings,
    required this.filter,
  });

  String _comparisonLabel() {
    return switch (filter) {
      DateRangeFilter.today => 'vs yesterday',
      DateRangeFilter.last7Days => AppStrings.vsLastWeek,
      DateRangeFilter.last30Days => AppStrings.vsPriorPeriod,
    };
  }

  double _averagePowerKw(List<SensorReading> readings) {
    if (readings.isEmpty) return 0;
    final sum = readings.map((r) => r.power).reduce((a, b) => a + b);
    return sum / readings.length / 1000;
  }

  double _powerPercentVsPrior(List<SensorReading> readings) {
    // Approximation: compare avg power in first vs second half of period
    if (readings.length < 4) return double.nan;
    final mid = readings.length ~/ 2;
    final first = readings.sublist(0, mid);
    final second = readings.sublist(mid);
    final avgFirst = _averagePowerKw(first);
    final avgSecond = _averagePowerKw(second);
    if (avgFirst <= 0) return avgSecond > 0 ? 100 : double.nan;
    return ((avgSecond - avgFirst) / avgFirst) * 100;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricFilter = ref.watch(historyMetricFilterProvider);
    final isEnergy = metricFilter == HistoryMetricFilter.energy;

    final pct = isEnergy
        ? stats.percentVsPriorPeriod
        : _powerPercentVsPrior(readings);
    final hasPct = pct.isFinite;

    final mainValue = isEnergy
        ? '${formatKwh(stats.displayKwh)} kWh'
        : '${_averagePowerKw(readings).toStringAsFixed(1)} kW';

    final cardTitle =
        isEnergy ? AppStrings.energyUsageKwh : AppStrings.powerUsageKw;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.md,
              AppDimensions.lg,
              AppDimensions.md,
              AppDimensions.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cardTitle,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textMuted,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                ),
                const SizedBox(height: AppDimensions.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        mainValue,
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              height: 1,
                              fontSize: 36,
                            ),
                      ),
                    ),
                    if (hasPct && !isEnergy)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(0)}% ${_comparisonLabel()}',
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: pct >= 0
                                        ? AppColors.online
                                        : const Color(0xFFE57373),
                                    fontWeight: FontWeight.w600,
                                  ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          EnergyChart(
            readings: readings,
            filter: filter,
            metricFilter: metricFilter,
            compact: true,
          ),
          const SizedBox(height: AppDimensions.sm),
        ],
      ),
    );
  }
}
