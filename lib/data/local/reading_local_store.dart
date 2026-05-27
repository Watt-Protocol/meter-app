import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sensor_reading.dart';
import '../../core/utils/date_range_utils.dart';

/// Persists sensor readings on device: show cached data instantly, append on sync.
class ReadingLocalStore {
  static const _maxDayRows = 3000;

  Future<SensorReading?> loadLatest(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_latestKey(deviceId));
    if (raw == null || raw.isEmpty) return null;
    try {
      return SensorReading.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveLatest(String deviceId, SensorReading reading) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_latestKey(deviceId), jsonEncode(reading.toJson()));
    await prefs.setString(
      _syncCursorKey(deviceId),
      reading.createdAt.toUtc().toIso8601String(),
    );
  }

  Future<String?> loadSyncCursor(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_syncCursorKey(deviceId));
  }

  Future<List<SensorReading>> loadDayReadings(
    String deviceId,
    DateTime day,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_dayKey(deviceId, day));
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => SensorReading.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } catch (_) {
      return [];
    }
  }

  Future<void> saveDayReadings(
    String deviceId,
    DateTime day,
    List<SensorReading> readings,
  ) async {
    if (readings.isEmpty) return;
    final sorted = List<SensorReading>.from(readings)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final trimmed = sorted.length > _maxDayRows
        ? sorted.sublist(sorted.length - _maxDayRows)
        : sorted;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _dayKey(deviceId, day),
      jsonEncode(trimmed.map((r) => r.toJson()).toList()),
    );
  }

  Future<void> appendDayReadings(
    String deviceId,
    DateTime day,
    List<SensorReading> incoming,
  ) async {
    if (incoming.isEmpty) return;
    final existing = await loadDayReadings(deviceId, day);
    final ids = existing.map((r) => r.id).where((id) => id.isNotEmpty).toSet();
    final merged = List<SensorReading>.from(existing);
    for (final r in incoming) {
      if (r.id.isNotEmpty && ids.contains(r.id)) continue;
      merged.add(r);
      if (r.id.isNotEmpty) ids.add(r.id);
    }
    await saveDayReadings(deviceId, day, merged);
  }

  Future<void> clearDevice(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_latestKey(deviceId));
    await prefs.remove(_syncCursorKey(deviceId));
    final keys = prefs.getKeys().where((k) => k.startsWith('watt_day_${deviceId}_'));
    for (final k in keys) {
      await prefs.remove(k);
    }
  }

  String _latestKey(String deviceId) => 'watt_latest_$deviceId';

  String _syncCursorKey(String deviceId) => 'watt_sync_cursor_$deviceId';

  String _dayKey(String deviceId, DateTime day) {
    final d = DateRangeUtils.startOfLocalDay(day);
    return 'watt_day_${deviceId}_${d.year}-${d.month}-${d.day}';
  }
}
