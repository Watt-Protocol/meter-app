import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/consumption_display.dart';
import '../../core/utils/date_range_utils.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/energy_utils.dart';
import '../models/history_stats.dart';
import '../models/sensor_reading.dart';
import '../models/user_profile.dart';
import '../repositories/mining_events_repository.dart';
import '../repositories/supabase_data_repository.dart';
import '../repositories/firebase_data_repository.dart';
import '../repositories/sensor_repository.dart';
import '../repositories/user_profile_repository.dart';
import 'auth_providers.dart';
import 'settings_providers.dart';

/// Supabase data repo instance.
final supabaseDataRepoProvider = Provider<SupabaseDataRepository>((ref) {
  return SupabaseDataRepository(Supabase.instance.client);
});

/// Firebase data repo instance.
final firebaseDataRepoProvider = Provider<FirebaseDataRepository?>((ref) {
  try {
    return FirebaseDataRepository(FirebaseDatabase.instance);
  } catch (_) {
    return null;
  }
});

/// Orchestrated sensor repository (Supabase → Firebase fallback).
final sensorRepositoryProvider = Provider<SensorRepository>((ref) {
  return SensorRepository(
    supabaseRepo: ref.watch(supabaseDataRepoProvider),
    firebaseRepo: ref.watch(firebaseDataRepoProvider),
  );
});

/// Local cache first, then Supabase Realtime append (no 15s full refetch loop).
final latestReadingProvider = StreamProvider<SensorReading?>((ref) {
  final deviceId = ref.watch(deviceIdProvider);
  final repo = ref.watch(sensorRepositoryProvider);
  return repo.watchLatestReading(deviceId);
});

/// Slow tick for optional background sync (mining list), not full UI invalidation.
final liveDataTickProvider = StreamProvider.autoDispose<int>((ref) async* {
  var tick = 0;
  yield tick++;
  await for (final _ in Stream.periodic(const Duration(minutes: 2))) {
    yield tick++;
  }
});

/// Active data source (supabase / firebase / none).
final dataSourceProvider = Provider<DataSource>((ref) {
  ref.watch(latestReadingProvider);
  return ref.watch(sensorRepositoryProvider).activeSource;
});

/// Online when last reading is within [onlineThresholdSeconds] (firmware posts ~15s).
const int onlineThresholdSeconds = 60;

enum MeterConnectivity { none, stale, live }

MeterConnectivity meterConnectivityFromReading(SensorReading? reading) {
  if (reading == null) return MeterConnectivity.none;
  final diff = DateTime.now().difference(reading.createdAt);
  if (diff.inSeconds < onlineThresholdSeconds) return MeterConnectivity.live;
  return MeterConnectivity.stale;
}

/// Live vs stale vs no data (dashboard badge and sections).
final meterConnectivityProvider = Provider<MeterConnectivity>((ref) {
  final readingAsync = ref.watch(latestReadingProvider);
  final connectivity = readingAsync.whenOrNull(
        data: (reading) => meterConnectivityFromReading(reading),
      ) ??
      MeterConnectivity.none;
  return connectivity;
});

/// Whether the device is online (recent reading in Supabase/Firebase).
final deviceOnlineProvider = Provider<bool>((ref) {
  return ref.watch(meterConnectivityProvider) == MeterConnectivity.live;
});

/// Date range filter for history screen.
enum DateRangeFilter { today, last7Days, last30Days }

/// Currently selected date range filter (default: today).
final dateRangeFilterProvider =
    NotifierProvider<DateRangeFilterNotifier, DateRangeFilter>(
        DateRangeFilterNotifier.new);

class DateRangeFilterNotifier extends Notifier<DateRangeFilter> {
  @override
  DateRangeFilter build() => DateRangeFilter.today;

  void setFilter(DateRangeFilter filter) {
    state = filter;
  }
}

/// Chart metric filter on the history screen (energy vs power).
enum HistoryMetricFilter { energy, power }

final historyMetricFilterProvider =
    NotifierProvider<HistoryMetricFilterNotifier, HistoryMetricFilter>(
  HistoryMetricFilterNotifier.new,
);

class HistoryMetricFilterNotifier extends Notifier<HistoryMetricFilter> {
  @override
  HistoryMetricFilter build() => HistoryMetricFilter.energy;

  void setFilter(HistoryMetricFilter filter) {
    state = filter;
  }
}

/// Today's readings list — updates when [todayUsageProvider] refreshes (no full refetch UI).
final todayReadingsListProvider = Provider<List<SensorReading>>((ref) {
  ref.watch(todayUsageProvider);
  return ref.watch(sensorRepositoryProvider).todayReadingsSnapshot;
});

/// Historical readings for the selected date range.
final readingsHistoryProvider = Provider<AsyncValue<List<SensorReading>>>((ref) {
  final filter = ref.watch(dateRangeFilterProvider);

  if (filter == DateRangeFilter.today) {
    ref.watch(todayUsageProvider);
    final snapshot = ref.watch(todayReadingsListProvider);
    if (snapshot.isNotEmpty) {
      return AsyncValue.data(snapshot);
    }
    final latest =
        ref.watch(latestReadingProvider).whenOrNull(data: (r) => r);
    if (latest != null) {
      return AsyncValue.data([latest]);
    }
    return const AsyncValue.data([]);
  }

  return ref.watch(periodReadingsHistoryProvider);
});

/// 7-day / 30-day readings (today uses in-memory cache via [todayUsageProvider]).
final periodReadingsHistoryProvider =
    FutureProvider<List<SensorReading>>((ref) async {
  final deviceId = ref.watch(deviceIdProvider);
  final filter = ref.watch(dateRangeFilterProvider);
  final repo = ref.watch(sensorRepositoryProvider);
  final now = DateTime.now();
  final (from, to) = _dateRangeForFilter(filter, now);
  return repo.getReadings(deviceId, from: from, to: to);
});

/// Aggregated history stats for the selected meter and date range.
final historyStatsProvider = Provider<AsyncValue<HistoryStats>>((ref) {
  final filter = ref.watch(dateRangeFilterProvider);
  if (filter == DateRangeFilter.today) {
    return ref.watch(_todayHistoryStatsProvider);
  }
  return ref.watch(periodHistoryStatsProvider);
});

final _todayHistoryStatsProvider = Provider<AsyncValue<HistoryStats>>((ref) {
  final usage = ref.watch(todayUsageProvider);
  return usage.when(
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
    data: (_) {
      final stats = ref.watch(_todayHistoryStatsSyncProvider);
      return stats != null ? AsyncValue.data(stats) : const AsyncValue.loading();
    },
  );
});

HistoryStats _buildHistoryStats({
  required List<SensorReading> readings,
  required SensorReading? baseline,
  required List<SensorReading> priorReadings,
  required SensorReading? priorBaseline,
  required DateTime from,
  required DateTime to,
  required String deviceId,
  required String filterName,
}) {
  final periodKwh = computePeriodKwh(readings, baseline: baseline);
  final priorKwh = computePeriodKwh(priorReadings, baseline: priorBaseline);

  double percentVsPriorPeriod;
  if (priorKwh > 0) {
    percentVsPriorPeriod = ((periodKwh - priorKwh) / priorKwh) * 100;
  } else if (periodKwh > 0) {
    percentVsPriorPeriod = 100;
  } else {
    percentVsPriorPeriod = double.nan;
  }

  final peakPowerW = readings.isEmpty
      ? 0.0
      : readings.map((r) => r.power).reduce((a, b) => a > b ? a : b);

  final periodMinutes = to.difference(from).inMinutes.clamp(1, 999999);
  final uptimePercent =
      (readings.length / periodMinutes * 100).clamp(0.0, 100.0);

  return HistoryStats(
    periodKwh: periodKwh,
    mintedKwh: 0,
    percentVsPriorPeriod: percentVsPriorPeriod,
    peakPowerKw: peakPowerW / 1000,
    uptimePercent: uptimePercent,
  );
}

final _todayHistoryStatsSyncProvider = Provider<HistoryStats?>((ref) {
  ref.watch(todayUsageProvider);
  final deviceId = ref.watch(deviceIdProvider);
  final repo = ref.read(sensorRepositoryProvider);
  final readings = repo.todayReadingsSnapshot;

  final now = DateTime.now();
  final (from, to) = DateRangeUtils.localDayRange(now);
  final yesterday = repo.yesterdayBundleSnapshot;

  return _buildHistoryStats(
    readings: readings,
    baseline: repo.todayBaselineSnapshot,
    priorReadings: yesterday?.readings ?? const [],
    priorBaseline: yesterday?.baseline,
    from: from,
    to: to,
    deviceId: deviceId,
    filterName: 'today',
  );
});

/// 7-day / 30-day stats (today uses sync stats from day cache).
final periodHistoryStatsProvider =
    FutureProvider<HistoryStats>((ref) async {
  final deviceId = ref.watch(deviceIdProvider);
  final filter = ref.watch(dateRangeFilterProvider);
  final repo = ref.watch(sensorRepositoryProvider);
  final now = DateTime.now();
  final (from, to) = _dateRangeForFilter(filter, now);
  final (priorFrom, priorTo) = _priorPeriodForFilter(filter, now);

  final readings = await repo.getReadings(deviceId, from: from, to: to);
  final priorReadings =
      await repo.getReadings(deviceId, from: priorFrom, to: priorTo);
  final baseline = await repo.getLastReadingBefore(deviceId, from);
  final priorBaseline = await repo.getLastReadingBefore(deviceId, priorFrom);

  return _buildHistoryStats(
    readings: readings,
    baseline: baseline,
    priorReadings: priorReadings,
    priorBaseline: priorBaseline,
    from: from,
    to: to,
    deviceId: deviceId,
    filterName: filter.name,
  );
});

/// User profile for rewards card (waitlist_users via RPC).
final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepository(Supabase.instance.client);
});

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  ref.watch(todayUsageProvider);
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  return ref.watch(userProfileRepositoryProvider).fetchProfile(userId);
});

/// Today's kWh — cached day readings; live samples append without full reload.
final todayUsageProvider =
    AsyncNotifierProvider<TodayUsageNotifier, TodayUsageStats>(
  TodayUsageNotifier.new,
);

class TodayUsageNotifier extends AsyncNotifier<TodayUsageStats> {
  @override
  Future<TodayUsageStats> build() async {
    ref.listen(deviceIdProvider, (previous, next) {
      if (previous != next) {
        ref.read(sensorRepositoryProvider).clearDayCache();
        unawaited(_reload());
      }
    });

    ref.listen(latestReadingProvider, (previous, next) {
      next.whenData((reading) {
        if (reading != null) unawaited(_onLiveReading(reading));
      });
    });

    return _compute();
  }

  Future<void> _reload() async {
    final repo = ref.read(sensorRepositoryProvider);
    final deviceId = ref.read(deviceIdProvider);
    await repo.getTodayReadingsBundle(deviceId, forceRefresh: true);
    final stats = await _compute();
    state = AsyncData(stats);
  }

  Future<void> _onLiveReading(SensorReading reading) async {
    final deviceId = ref.read(deviceIdProvider);
    final repo = ref.read(sensorRepositoryProvider);
    await repo.syncTodayReadings(deviceId, DateTime.now());
    final stats = await _compute();
    if (!ref.mounted) return;
    state = AsyncData(stats);
  }

  Future<TodayUsageStats> _compute() async {
    final deviceId = ref.read(deviceIdProvider);
    final repo = ref.read(sensorRepositoryProvider);
    final now = DateTime.now();

    final today = await repo.getTodayReadingsBundle(deviceId, to: now);
    await repo.getYesterdayReadingsBundle(deviceId);

    final meterKwh =
        computePeriodKwh(today.readings, baseline: today.baseline);

    var mintedKwh = 0.0;
    final userId = ref.read(currentUserIdProvider);
    if (userId != null) {
      final dayStart = DateTime(now.year, now.month, now.day);
      final miningRepo = MiningEventsRepository(Supabase.instance.client);
      final events = await miningRepo.fetchEvents(
        userId: userId,
        from: dayStart,
        to: now,
      );
      mintedKwh = events
          .where((e) => e.isUserTransferConfirmed)
          .fold<double>(0, (sum, e) => sum + e.kwh);
    }

    final todayKwh = consumptionDisplayKwh(
      meterKwh: meterKwh,
      mintedKwh: mintedKwh,
      pendingKwh: 0,
    );

    if (kDebugMode && todayKwh == 0 && today.readings.isNotEmpty) {
      debugPrint(
        '[todayUsage] device=$deviceId todayRows=${today.readings.length} '
        'baselineEnergy=${today.baseline?.energy} '
        'latestEnergy=${today.readings.last.energy}',
      );
    }

    String? statusHint;
    if (today.readings.isEmpty) {
      final latest = await repo.getLatestReading(deviceId);
      if (latest != null) {
        final todayStart = DateRangeUtils.startOfLocalDay(now);
        if (latest.createdAt.isBefore(todayStart)) {
          statusHint = AppDateUtils.lastReadingAgo(latest.createdAt);
        }
      }
    } else if (meterKwh == 0 &&
        mintedKwh == 0 &&
        today.readings.length < 2 &&
        today.baseline == null) {
      statusHint = AppStrings.powerVsEnergyHint;
    }

    return TodayUsageStats(
      todayKwh: todayKwh,
      statusHint: statusHint,
    );
  }
}

/// Last power samples for the oscilloscope bar chart.
final oscilloscopeReadingsProvider =
    FutureProvider<List<double>>((ref) async {
  final deviceId = ref.watch(deviceIdProvider);
  final repo = ref.watch(sensorRepositoryProvider);
  final now = DateTime.now();
  final from = now.subtract(const Duration(minutes: 6));

  ref.listen(latestReadingProvider, (previous, next) {
    next.whenData((_) {
      ref.invalidateSelf();
    });
  });

  final readings = await repo.getReadings(deviceId, from: from, to: now);
  final powers = readings.map((r) => r.power).toList();
  if (powers.length > 24) {
    return powers.sublist(powers.length - 24);
  }
  return powers;
});

(DateTime from, DateTime to) _dateRangeForFilter(
  DateRangeFilter filter,
  DateTime now,
) {
  switch (filter) {
    case DateRangeFilter.today:
      return DateRangeUtils.localDayRange(now);
    case DateRangeFilter.last7Days:
      return (now.subtract(const Duration(days: 7)), now);
    case DateRangeFilter.last30Days:
      return (now.subtract(const Duration(days: 30)), now);
  }
}

(DateTime from, DateTime to) _priorPeriodForFilter(
  DateRangeFilter filter,
  DateTime now,
) {
  switch (filter) {
    case DateRangeFilter.today:
      return DateRangeUtils.previousLocalDayRange(now);
    case DateRangeFilter.last7Days:
      final currentFrom = now.subtract(const Duration(days: 7));
      return (now.subtract(const Duration(days: 14)), currentFrom);
    case DateRangeFilter.last30Days:
      final currentFrom = now.subtract(const Duration(days: 30));
      return (now.subtract(const Duration(days: 60)), currentFrom);
  }
}
