import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/history_stats.dart';
import 'mining_providers.dart';
import 'sensor_providers.dart';

/// Sensor + mining totals for the history energy headline (same date filter).
final historyStatsWithMiningProvider =
    Provider<AsyncValue<HistoryStats>>((ref) {
  final statsAsync = ref.watch(historyStatsProvider);
  final summary = ref.watch(miningSummaryProvider);
  final filter = ref.watch(dateRangeFilterProvider);
  final pendingKwh = filter == DateRangeFilter.today
      ? (ref.watch(userProfileProvider).whenOrNull(
            data: (p) => p?.pendingWatt,
          ) ??
          0)
      : 0.0;

  // Show energy stats as soon as sensor data is ready; merge mining totals when loaded.
  if (statsAsync.isLoading && !statsAsync.hasValue) {
    return const AsyncValue.loading();
  }

  return statsAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
    data: (stats) {
      final minted = summary.totalKwh;
      return AsyncValue.data(
        HistoryStats(
          periodKwh: stats.periodKwh,
          mintedKwh: minted,
          pendingKwh: pendingKwh,
          percentVsPriorPeriod: stats.percentVsPriorPeriod,
          peakPowerKw: stats.peakPowerKw,
          uptimePercent: stats.uptimePercent,
        ),
      );
    },
  );
});
