import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../models/sensor_reading.dart';
import '../../core/config/supabase_config.dart';

/// Fallback data source — reads sensor data from Firebase Realtime Database.
class FirebaseDataRepository {
  final FirebaseDatabase _database;

  FirebaseDataRepository(this._database);

  /// Get reference to a device's latest reading path.
  DatabaseReference _latestRef(String deviceId) {
    return _database
        .ref()
        .child(SupabaseConfig.firebaseDevicesPath)
        .child(deviceId)
        .child('latest');
  }

  /// Get reference to a device's readings history path.
  DatabaseReference _historyRef(String deviceId) {
    return _database
        .ref()
        .child(SupabaseConfig.firebaseDevicesPath)
        .child(deviceId)
        .child('readings');
  }

  /// Fetch the latest reading once.
  Future<SensorReading?> getLatestReading(String deviceId) async {
    final snapshot = await _latestRef(deviceId).get();
    if (!snapshot.exists || snapshot.value == null) return null;

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    return SensorReading.fromFirebase(data, deviceId);
  }

  /// Stream the latest reading in real time.
  Stream<SensorReading> streamLatestReading(String deviceId) {
    return _latestRef(deviceId).onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        throw Exception('No readings available from Firebase');
      }
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      return SensorReading.fromFirebase(data, deviceId);
    });
  }

  /// Fetch historical readings within a date range.
  Future<List<SensorReading>> getReadings(
    String deviceId, {
    required DateTime from,
    required DateTime to,
  }) async {
    final snapshot = await _historyRef(deviceId)
        .orderByChild('timestamp')
        .startAt(from.millisecondsSinceEpoch)
        .endAt(to.millisecondsSinceEpoch)
        .get();

    if (!snapshot.exists || snapshot.value == null) return [];

    final Map<String, dynamic> data =
        Map<String, dynamic>.from(snapshot.value as Map);

    return data.values
        .map((v) => SensorReading.fromFirebase(
              Map<String, dynamic>.from(v as Map),
              deviceId,
            ))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Last reading strictly before [before].
  Future<SensorReading?> getLastReadingBefore(
    String deviceId,
    DateTime before,
  ) async {
    final from = before.subtract(const Duration(days: 30));
    final readings = await getReadings(deviceId, from: from, to: before);
    if (readings.isEmpty) return null;
    return readings.last;
  }
}
