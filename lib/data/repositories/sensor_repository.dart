import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/utils/date_range_utils.dart';
import '../models/day_readings_bundle.dart';
import '../models/sensor_reading.dart';
import '../local/reading_local_store.dart';
import 'supabase_data_repository.dart';
import 'firebase_data_repository.dart';

/// Which backend is currently serving data.
enum DataSource { supabase, firebase, none }

class _ReadingsCacheEntry {
  final List<SensorReading> readings;
  final DateTime expiresAt;
  final DateTime? newestAt;

  _ReadingsCacheEntry({
    required this.readings,
    required this.expiresAt,
    this.newestAt,
  });
}

/// Orchestrates data access: tries Supabase first, falls back to Firebase.
class SensorRepository {
  final SupabaseDataRepository _supabaseRepo;
  final FirebaseDataRepository? _firebaseRepo;
  final ReadingLocalStore _localStore;

  DataSource _activeSource = DataSource.none;
  DateTime? _lastRealtimeEmit;

  static const _readingsCacheTtl = Duration(minutes: 5);
  final Map<String, _ReadingsCacheEntry> _readingsCache = {};

  String? _dayDeviceId;
  DateTime? _dayLocalStart;
  List<SensorReading> _dayReadings = [];
  SensorReading? _dayBaseline;
  bool _dayFullyLoaded = false;
  SensorReading? _pendingLiveReading;

  String? _yesterdayDeviceId;
  DateTime? _yesterdayLocalStart;
  DayReadingsBundle? _yesterdayBundle;

  SensorRepository({
    required SupabaseDataRepository supabaseRepo,
    FirebaseDataRepository? firebaseRepo,
    ReadingLocalStore? localStore,
  })  : _supabaseRepo = supabaseRepo,
        _firebaseRepo = firebaseRepo,
        _localStore = localStore ?? ReadingLocalStore();

  /// Cached latest from on-device storage (instant UI on cold start).
  Future<SensorReading?> getCachedLatestReading(String deviceId) =>
      _localStore.loadLatest(deviceId);

  Future<void> _persistLatest(String deviceId, SensorReading reading) async {
    await _localStore.saveLatest(deviceId, reading);
  }

  Future<void> _persistDayCache(String deviceId) async {
    if (_dayLocalStart == null || _dayReadings.isEmpty) return;
    await _localStore.saveDayReadings(deviceId, _dayLocalStart!, _dayReadings);
  }

  /// Which backend is currently active.
  DataSource get activeSource => _activeSource;

  /// In-memory today readings (empty until [getTodayReadingsBundle] runs).
  List<SensorReading> get todayReadingsSnapshot =>
      List.unmodifiable(_dayReadings);

  SensorReading? get todayBaselineSnapshot => _dayBaseline;

  DayReadingsBundle? get yesterdayBundleSnapshot => _yesterdayBundle;

  /// Fetch the latest reading; prefers whichever backend is fresher.
  Future<SensorReading?> getLatestReading(String deviceId) async {
    SensorReading? supabaseReading;
    try {
      supabaseReading = await _supabaseRepo
          .getLatestReading(deviceId)
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('[SensorRepository] Supabase failed: $e — trying Firebase');
    }

    SensorReading? firebaseReading;
    if (_firebaseRepo != null) {
      try {
        firebaseReading = await _firebaseRepo!
            .getLatestReading(deviceId)
            .timeout(const Duration(seconds: 10));
      } catch (e) {
        debugPrint('[SensorRepository] Firebase also failed: $e');
      }
    }

    if (supabaseReading != null && firebaseReading != null) {
      _activeSource = supabaseReading.createdAt.isAfter(firebaseReading.createdAt)
          ? DataSource.supabase
          : DataSource.firebase;
      final chosen = supabaseReading.createdAt.isAfter(firebaseReading.createdAt)
          ? supabaseReading
          : firebaseReading;
      _appendLiveReadingToDayCache(deviceId, chosen);
      await _persistLatest(deviceId, chosen);
      return chosen;
    }

    if (supabaseReading != null) {
      _activeSource = DataSource.supabase;
      _appendLiveReadingToDayCache(deviceId, supabaseReading);
      await _persistLatest(deviceId, supabaseReading);
      return supabaseReading;
    }
    if (firebaseReading != null) {
      _activeSource = DataSource.firebase;
      _appendLiveReadingToDayCache(deviceId, firebaseReading);
      await _persistLatest(deviceId, firebaseReading);
      return firebaseReading;
    }

    _activeSource = DataSource.none;
    return null;
  }

  /// Cache-first live stream: local storage → one network sync → realtime append.
  /// Background fallback sync only if realtime is silent for 90s (no 15s full refetch).
  Stream<SensorReading?> watchLatestReading(String deviceId) {
    late StreamController<SensorReading?> controller;
    StreamSubscription<SensorReading>? realtimeSub;
    Timer? fallbackTimer;
    SensorReading? lastEmitted;

    Future<void> emitIfNew(SensorReading? reading) async {
      if (reading == null || controller.isClosed) return;
      if (lastEmitted != null &&
          lastEmitted!.id.isNotEmpty &&
          lastEmitted!.id == reading.id) {
        return;
      }
      if (lastEmitted != null &&
          !reading.createdAt.isAfter(lastEmitted!.createdAt)) {
        return;
      }
      lastEmitted = reading;
      _lastRealtimeEmit = DateTime.now();
      await _persistLatest(deviceId, reading);
      _appendLiveReadingToDayCache(deviceId, reading);
      if (!controller.isClosed) controller.add(reading);
    }

    Future<void> bootstrap() async {
      final cached = await _localStore.loadLatest(deviceId);
      if (cached != null) {
        lastEmitted = cached;
        if (!controller.isClosed) controller.add(cached);
        _hydrateDayFromLocal(deviceId);
      }

      final fresh = await getLatestReading(deviceId);
      await emitIfNew(fresh);
    }

    controller = StreamController<SensorReading?>(
      onListen: () {
        bootstrap();

        _activeSource = DataSource.supabase;
        realtimeSub = _supabaseRepo.watchLatestChanges(deviceId).listen(
          (reading) => emitIfNew(reading),
          onError: (e) {
            debugPrint('[SensorRepository] Realtime error: $e');
          },
        );

        fallbackTimer = Timer.periodic(const Duration(seconds: 90), (_) async {
          final last = _lastRealtimeEmit;
          if (last != null &&
              DateTime.now().difference(last) < const Duration(seconds: 75)) {
            return;
          }
          final reading = await getLatestReading(deviceId);
          await emitIfNew(reading);
        });
      },
      onCancel: () {
        realtimeSub?.cancel();
        fallbackTimer?.cancel();
      },
    );

    return controller.stream;
  }

  void _hydrateDayFromLocal(String deviceId) {
    final dayStart = DateRangeUtils.startOfLocalDay(DateTime.now());
    _resetDayCacheIfNeeded(deviceId, dayStart);
    _localStore.loadDayReadings(deviceId, dayStart).then((local) {
      if (local.isEmpty) return;
      _mergeUniqueReadings(local);
      _dayFullyLoaded = true;
    });
  }

  String _readingsCacheKey(String deviceId, DateTime from, DateTime to) {
    return '$deviceId|${from.toUtc().toIso8601String()}|${to.toUtc().toIso8601String()}';
  }

  void _invalidateReadingsCacheForDevice(String deviceId) {
    _readingsCache.removeWhere((key, _) => key.startsWith('$deviceId|'));
  }

  void clearDayCache() {
    _dayDeviceId = null;
    _dayLocalStart = null;
    _dayReadings = [];
    _dayBaseline = null;
    _dayFullyLoaded = false;
    _pendingLiveReading = null;
    _yesterdayDeviceId = null;
    _yesterdayLocalStart = null;
    _yesterdayBundle = null;
  }

  void _resetDayCacheIfNeeded(String deviceId, DateTime dayStart) {
    if (_dayDeviceId != deviceId ||
        _dayLocalStart == null ||
        !_sameLocalDay(_dayLocalStart!, dayStart)) {
      _dayDeviceId = deviceId;
      _dayLocalStart = dayStart;
      _dayReadings = [];
      _dayBaseline = null;
      _dayFullyLoaded = false;
      _pendingLiveReading = null;
    }
  }

  bool _sameLocalDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _mergeUniqueReadings(List<SensorReading> incoming) {
    if (incoming.isEmpty) return;
    final ids = _dayReadings.map((r) => r.id).toSet();
    for (final r in incoming) {
      if (r.id.isNotEmpty && ids.contains(r.id)) continue;
      if (_dayReadings.isNotEmpty &&
          !r.createdAt.isAfter(_dayReadings.last.createdAt)) {
        continue;
      }
      _dayReadings.add(r);
      if (r.id.isNotEmpty) ids.add(r.id);
    }
    _dayReadings.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  void _appendLiveReadingToDayCache(String deviceId, SensorReading reading) {
    final dayStart = DateRangeUtils.startOfLocalDay(DateTime.now());
    if (reading.createdAt.isBefore(dayStart)) return;

    _resetDayCacheIfNeeded(deviceId, dayStart);
    if (!_dayFullyLoaded) {
      final pending = _pendingLiveReading;
      if (pending == null ||
          reading.createdAt.isAfter(pending.createdAt)) {
        _pendingLiveReading = reading;
      }
      return;
    }

    final before = _dayReadings.length;
    _mergeUniqueReadings([reading]);
    if (_dayReadings.length > before) {
    }
  }

  Future<void> syncTodayReadings(String deviceId, DateTime to) async {
    final dayStart = DateRangeUtils.startOfLocalDay(to);
    _resetDayCacheIfNeeded(deviceId, dayStart);

    if (!_dayFullyLoaded) {
      await getTodayReadingsBundle(deviceId, to: to);
      return;
    }

    if (_dayReadings.isEmpty) {
      return;
    }

    final lastAt = _dayReadings.last.createdAt;
    if (!to.isAfter(lastAt)) return;

    try {
      final delta = await _supabaseRepo
          .getReadingsAfter(deviceId, after: lastAt, to: to)
          .timeout(const Duration(seconds: 20));
      final before = _dayReadings.length;
      _mergeUniqueReadings(delta);
      if (_dayReadings.length > before) {
        await _persistDayCache(deviceId);
      }
    } catch (e) {
      debugPrint('[SensorRepository] syncTodayReadings delta failed: $e');
    }
  }

  /// Full or incremental load for the current local day (cached in memory).
  Future<DayReadingsBundle> getTodayReadingsBundle(
    String deviceId, {
    DateTime? to,
    bool forceRefresh = false,
  }) async {
    final end = to ?? DateTime.now();
    final dayStart = DateRangeUtils.startOfLocalDay(end);
    _resetDayCacheIfNeeded(deviceId, dayStart);

    if (forceRefresh) {
      _dayReadings = [];
      _dayBaseline = null;
      _dayFullyLoaded = false;
      _pendingLiveReading = null;
    }

    if (!_dayFullyLoaded) {
      final localDay = await _localStore.loadDayReadings(deviceId, dayStart);
      if (localDay.isNotEmpty && !forceRefresh) {
        _dayReadings = List<SensorReading>.from(localDay);
        _dayFullyLoaded = true;
        final cursor = await _localStore.loadSyncCursor(deviceId);
        if (cursor != null) {
          final after = DateTime.tryParse(cursor) ?? dayStart;
          if (end.isAfter(after)) {
            try {
              final delta = await _supabaseRepo.getReadingsAfter(
                deviceId,
                after: after,
                to: end,
              );
              _mergeUniqueReadings(delta);
              await _localStore.appendDayReadings(deviceId, dayStart, delta);
            } catch (e) {
              debugPrint('[SensorRepository] incremental day sync: $e');
            }
          }
        }
      } else {
        _dayBaseline = await getLastReadingBefore(deviceId, dayStart);
        _dayReadings = List<SensorReading>.from(
          await getReadings(deviceId, from: dayStart, to: end),
        );
        _dayFullyLoaded = true;
        await _persistDayCache(deviceId);
      }
      final pending = _pendingLiveReading;
      if (pending != null) {
        _mergeUniqueReadings([pending]);
        _pendingLiveReading = null;
      }
    } else {
      await syncTodayReadings(deviceId, end);
    }

    _dayBaseline ??= await getLastReadingBefore(deviceId, dayStart);

    return DayReadingsBundle(
      readings: List.unmodifiable(_dayReadings),
      baseline: _dayBaseline,
      dayStart: dayStart,
    );
  }

  /// Yesterday's readings (loaded once per device/day, then cached).
  Future<DayReadingsBundle> getYesterdayReadingsBundle(String deviceId) async {
    final now = DateTime.now();
    final (yesterdayStart, todayStart) =
        DateRangeUtils.previousLocalDayRange(now);

    if (_yesterdayDeviceId == deviceId &&
        _yesterdayLocalStart != null &&
        _sameLocalDay(_yesterdayLocalStart!, yesterdayStart) &&
        _yesterdayBundle != null) {
      return _yesterdayBundle!;
    }

    final baseline = await getLastReadingBefore(deviceId, yesterdayStart);
    final readings = await getReadings(
      deviceId,
      from: yesterdayStart,
      to: todayStart,
    );

    _yesterdayDeviceId = deviceId;
    _yesterdayLocalStart = yesterdayStart;
    _yesterdayBundle = DayReadingsBundle(
      readings: readings,
      baseline: baseline,
      dayStart: yesterdayStart,
    );
    return _yesterdayBundle!;
  }

  void _storeReadingsCache(
    String key,
    List<SensorReading> readings,
  ) {
    DateTime? newest;
    if (readings.isNotEmpty) {
      newest = readings
          .map((r) => r.createdAt)
          .reduce((a, b) => a.isAfter(b) ? a : b);
    }
    _readingsCache[key] = _ReadingsCacheEntry(
      readings: readings,
      expiresAt: DateTime.now().add(_readingsCacheTtl),
      newestAt: newest,
    );
  }

  /// Fetch historical readings with fallback when Supabase is empty.
  Future<List<SensorReading>> getReadings(
    String deviceId, {
    required DateTime from,
    required DateTime to,
  }) async {
    final cacheKey = _readingsCacheKey(deviceId, from, to);
    final cached = _readingsCache[cacheKey];
    if (cached != null && DateTime.now().isBefore(cached.expiresAt)) {
      return cached.readings;
    }

    List<SensorReading> supabaseReadings = [];
    // Try Supabase first
    try {
      supabaseReadings = await _supabaseRepo
          .getReadings(deviceId, from: from, to: to)
          .timeout(const Duration(seconds: 45));
      if (supabaseReadings.isNotEmpty) {
        _activeSource = DataSource.supabase;
        if (_firebaseRepo != null) {
          try {
            final fbReadings = await _firebaseRepo!
                .getReadings(deviceId, from: from, to: to)
                .timeout(const Duration(seconds: 15));
            if (fbReadings.length > supabaseReadings.length) {
              _activeSource = DataSource.firebase;
              _storeReadingsCache(cacheKey, fbReadings);
              return fbReadings;
            }
          } catch (_) {}
        }
        _storeReadingsCache(cacheKey, supabaseReadings);
        return supabaseReadings;
      }
    } catch (e) {
      debugPrint('[SensorRepository] Supabase history failed: $e');
    }

    // Fallback to Firebase when Supabase empty or failed
    if (_firebaseRepo != null) {
      try {
        final readings = await _firebaseRepo!
            .getReadings(deviceId, from: from, to: to)
            .timeout(const Duration(seconds: 15));
        _activeSource = DataSource.firebase;
        if (readings.isNotEmpty) {
          _storeReadingsCache(cacheKey, readings);
        }
        return readings;
      } catch (e) {
        debugPrint('[SensorRepository] Firebase history also failed: $e');
      }
    }

    _activeSource = DataSource.none;
    return supabaseReadings;
  }

  /// Last reading before [before]; Supabase first, Firebase fallback.
  Future<SensorReading?> getLastReadingBefore(
    String deviceId,
    DateTime before,
  ) async {
    try {
      final reading = await _supabaseRepo
          .getLastReadingBefore(deviceId, before)
          .timeout(const Duration(seconds: 10));
      if (reading != null) {
        _activeSource = DataSource.supabase;
        return reading;
      }
    } catch (e) {
      debugPrint('[SensorRepository] getLastReadingBefore supabase failed: $e');
    }

    if (_firebaseRepo != null) {
      try {
        final reading = await _firebaseRepo!
            .getLastReadingBefore(deviceId, before)
            .timeout(const Duration(seconds: 10));
        if (reading != null) {
          _activeSource = DataSource.firebase;
        }
        return reading;
      } catch (e) {
        debugPrint('[SensorRepository] getLastReadingBefore firebase failed: $e');
      }
    }
    return null;
  }
}
