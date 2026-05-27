import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sensor_reading.dart';
import '../../core/config/supabase_config.dart';

/// PostgREST returns at most this many rows per request unless paginated.
const int _supabasePageSize = 1000;

/// Primary data source — reads sensor data from Supabase PostgreSQL.
class SupabaseDataRepository {
  final SupabaseClient _client;

  SupabaseDataRepository(this._client);

  /// Fetch the most recent reading for a device.
  Future<SensorReading?> getLatestReading(String deviceId) async {
    final response = await _client
        .from(SupabaseConfig.sensorReadingsTable)
        .select()
        .eq('device_id', deviceId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) {
      return null;
    }
    final reading = SensorReading.fromJson(response);
    return reading;
  }

  /// Realtime: emits when rows for [deviceId] change (insert/update). Skips empty snapshots.
  Stream<SensorReading> watchLatestChanges(String deviceId) {
    return _client
        .from(SupabaseConfig.sensorReadingsTable)
        .stream(primaryKey: ['id'])
        .eq('device_id', deviceId)
        .order('created_at', ascending: false)
        .limit(1)
        .where((rows) => rows.isNotEmpty)
        .map((rows) => SensorReading.fromJson(rows.first));
  }

  /// Fetch readings within a date range for charts/history.
  ///
  /// Paginates past PostgREST's default 1000-row cap so full-day history loads.
  Future<List<SensorReading>> getReadings(
    String deviceId, {
    required DateTime from,
    required DateTime to,
  }) async {
    final all = <SensorReading>[];
    var offset = 0;
    var pageIndex = 0;

    while (true) {
      final response = await _client
          .from(SupabaseConfig.sensorReadingsTable)
          .select()
          .eq('device_id', deviceId)
          .gte('created_at', from.toUtc().toIso8601String())
          .lte('created_at', to.toUtc().toIso8601String())
          .order('created_at', ascending: true)
          .range(offset, offset + _supabasePageSize - 1);

      final page = (response as List)
          .map((row) => SensorReading.fromJson(row as Map<String, dynamic>))
          .toList();

      if (page.isEmpty) break;

      all.addAll(page);
      pageIndex++;
      if (page.length < _supabasePageSize) break;
      offset += _supabasePageSize;
    }

    return all;
  }

  /// Readings strictly after [after] through [to] (for incremental sync).
  Future<List<SensorReading>> getReadingsAfter(
    String deviceId, {
    required DateTime after,
    required DateTime to,
  }) async {
    final all = <SensorReading>[];
    var offset = 0;
    final afterUtc = after.toUtc().toIso8601String();
    final toUtc = to.toUtc().toIso8601String();

    while (true) {
      final response = await _client
          .from(SupabaseConfig.sensorReadingsTable)
          .select()
          .eq('device_id', deviceId)
          .gt('created_at', afterUtc)
          .lte('created_at', toUtc)
          .order('created_at', ascending: true)
          .range(offset, offset + _supabasePageSize - 1);

      final page = (response as List)
          .map((row) => SensorReading.fromJson(row as Map<String, dynamic>))
          .toList();

      if (page.isEmpty) break;
      all.addAll(page);
      if (page.length < _supabasePageSize) break;
      offset += _supabasePageSize;
    }

    return all;
  }

  /// Last reading strictly before [before] (baseline for day boundaries).
  Future<SensorReading?> getLastReadingBefore(
    String deviceId,
    DateTime before,
  ) async {
    final response = await _client
        .from(SupabaseConfig.sensorReadingsTable)
        .select()
        .eq('device_id', deviceId)
        .lt('created_at', before.toUtc().toIso8601String())
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return SensorReading.fromJson(response);
  }
}
