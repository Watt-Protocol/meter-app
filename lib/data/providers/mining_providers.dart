import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/mining_event.dart';
import '../repositories/mining_events_repository.dart';
import 'auth_providers.dart';
import 'sensor_providers.dart';

/// Status filter for minting activity list.
enum MiningStatusFilter { all, pending, confirmed }

class MiningStatusFilterNotifier extends Notifier<MiningStatusFilter> {
  @override
  MiningStatusFilter build() => MiningStatusFilter.all;

  void setFilter(MiningStatusFilter filter) => state = filter;
}

final miningStatusFilterProvider =
    NotifierProvider<MiningStatusFilterNotifier, MiningStatusFilter>(
  MiningStatusFilterNotifier.new,
);

/// Sort order for minting activity list.
enum MiningSortOrder { newest, oldest, wattDesc, kwhDesc }

class MiningSortOrderNotifier extends Notifier<MiningSortOrder> {
  @override
  MiningSortOrder build() => MiningSortOrder.newest;

  void setOrder(MiningSortOrder order) => state = order;
}

final miningSortOrderProvider =
    NotifierProvider<MiningSortOrderNotifier, MiningSortOrder>(
  MiningSortOrderNotifier.new,
);

final miningEventsRepositoryProvider = Provider<MiningEventsRepository>((ref) {
  return MiningEventsRepository(Supabase.instance.client);
});

(DateTime from, DateTime to) miningDateRange(DateRangeFilter filter) {
  final now = DateTime.now();
  switch (filter) {
    case DateRangeFilter.today:
      return (DateTime(now.year, now.month, now.day), now);
    case DateRangeFilter.last7Days:
      return (now.subtract(const Duration(days: 7)), now);
    case DateRangeFilter.last30Days:
      return (now.subtract(const Duration(days: 30)), now);
  }
}

/// Cached mining events — reload on filter change or manual refresh, not every sensor tick.
final miningEventsProvider =
    AsyncNotifierProvider<MiningEventsNotifier, List<MiningEvent>>(
  MiningEventsNotifier.new,
);

class MiningEventsNotifier extends AsyncNotifier<List<MiningEvent>> {
  DateTime? _lastFetchAt;

  @override
  Future<List<MiningEvent>> build() async {
    ref.listen(dateRangeFilterProvider, (prev, next) {
      if (prev != next) unawaited(refresh());
    });

    ref.listen(liveDataTickProvider, (_, __) {
      final now = DateTime.now();
      if (_lastFetchAt != null &&
          now.difference(_lastFetchAt!) < const Duration(minutes: 2)) {
        return;
      }
      unawaited(refresh());
    });

    return _fetchEvents();
  }

  Future<List<MiningEvent>> _fetchEvents() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return [];

    final filter = ref.read(dateRangeFilterProvider);
    final (from, to) = miningDateRange(filter);
    final events = await ref.read(miningEventsRepositoryProvider).fetchEvents(
          userId: userId,
          from: from,
          to: to,
        );
    _lastFetchAt = DateTime.now();
    return events;
  }

  Future<void> refresh() async {
    final previous = state.value ?? const <MiningEvent>[];
    state = AsyncData(previous);
    try {
      final events = await _fetchEvents();
      if (ref.mounted) state = AsyncData(events);
    } catch (e, st) {
      if (ref.mounted) state = AsyncError(e, st);
    }
  }
}

/// Mining events after status filter and sort (for activity list UI).
final filteredMiningEventsProvider = Provider<List<MiningEvent>>((ref) {
  final eventsAsync = ref.watch(miningEventsProvider);
  final events = eventsAsync.whenOrNull(data: (d) => d) ?? [];
  final statusFilter = ref.watch(miningStatusFilterProvider);
  final sortOrder = ref.watch(miningSortOrderProvider);

  var filtered = events.where((e) {
    return switch (statusFilter) {
      MiningStatusFilter.all => true,
      MiningStatusFilter.pending => !e.isConfirmed,
      MiningStatusFilter.confirmed => e.isConfirmed,
    };
  }).toList();

  filtered = switch (sortOrder) {
    MiningSortOrder.newest => filtered
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    MiningSortOrder.oldest => filtered
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
    MiningSortOrder.wattDesc => filtered
      ..sort((a, b) => b.userWattReceived.compareTo(a.userWattReceived)),
    MiningSortOrder.kwhDesc => filtered
      ..sort((a, b) => b.kwh.compareTo(a.kwh)),
  };

  return filtered;
});

/// Lookup a mining event by id from the current period cache.
final miningEventByIdProvider =
    Provider.family<MiningEvent?, int>((ref, id) {
  final events = ref.watch(miningEventsProvider).value ?? [];
  for (final e in events) {
    if (e.id == id) return e;
  }
  return null;
});

/// Mining totals for the current local calendar day (dashboard).
final todayMiningSummaryProvider = FutureProvider<MiningSummary>((ref) async {
  ref.watch(miningEventsProvider);
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return MiningSummary.empty();

  final now = DateTime.now();
  final from = DateTime(now.year, now.month, now.day);
  return ref.watch(miningEventsRepositoryProvider).fetchSummary(
        userId: userId,
        from: from,
        to: now,
      );
});

/// Aggregated mining totals for the selected date range (derived from cached events).
final miningSummaryProvider = Provider<MiningSummary>((ref) {
  final events = ref.watch(miningEventsProvider).value ?? [];
  if (events.isEmpty) return MiningSummary.empty();

  var totalKwh = 0.0;
  var totalUserWatt = 0.0;
  var totalCif = 0.0;
  var confirmed = 0;
  var pending = 0;
  var failed = 0;

  for (final e in events) {
    totalKwh += e.kwh;
    totalUserWatt += e.userWattReceived;
    totalCif += e.cifAmount;
    if (e.isUserTransferConfirmed) {
      confirmed++;
    } else if (e.isFailed) {
      failed++;
    } else {
      pending++;
    }
  }

  return MiningSummary(
    totalKwh: totalKwh,
    totalWattGross: events.fold(0.0, (a, e) => a + e.wattGross),
    totalUserWatt: totalUserWatt,
    totalCifAmount: totalCif,
    countPending: pending,
    countConfirmed: confirmed,
    countFailed: failed,
  );
});

/// Most recent mining event (last 90 days) for dashboard snippet.
final latestMiningEventProvider = FutureProvider<MiningEvent?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;

  final now = DateTime.now();
  final from = now.subtract(const Duration(days: 90));
  final events = await ref.watch(miningEventsRepositoryProvider).fetchEvents(
        userId: userId,
        from: from,
        to: now,
      );
  if (events.isEmpty) return null;
  return events.first;
});
