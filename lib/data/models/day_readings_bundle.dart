import 'sensor_reading.dart';

/// Cached readings for one local calendar day plus optional midnight baseline.
class DayReadingsBundle {
  final List<SensorReading> readings;
  final SensorReading? baseline;
  final DateTime dayStart;

  const DayReadingsBundle({
    required this.readings,
    required this.baseline,
    required this.dayStart,
  });

  static DayReadingsBundle empty(DateTime dayStart) {
    return DayReadingsBundle(
      readings: const [],
      baseline: null,
      dayStart: dayStart,
    );
  }
}
