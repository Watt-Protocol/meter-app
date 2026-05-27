import '../../data/models/sensor_reading.dart';

/// Sum energy consumption from cumulative PZEM register readings.
///
/// Handles meter resets: when energy drops between consecutive samples,
/// starts a new segment instead of producing a negative total.
double sumEnergyConsumption(List<SensorReading> readings) {
  if (readings.isEmpty) return 0;
  if (readings.length == 1) return 0;

  final sorted = List<SensorReading>.from(readings)
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  double total = 0;
  for (var i = 1; i < sorted.length; i++) {
    final prev = sorted[i - 1].energy;
    final curr = sorted[i].energy;
    if (curr >= prev) {
      total += curr - prev;
    }
  }
  return total.clamp(0, double.infinity);
}

/// Estimate kWh by integrating average power between consecutive samples.
double integratePowerToKwh(List<SensorReading> readings) {
  if (readings.length < 2) return 0;

  final sorted = List<SensorReading>.from(readings)
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  double wattHours = 0;
  for (var i = 1; i < sorted.length; i++) {
    final dtHours = sorted[i]
        .createdAt
        .difference(sorted[i - 1].createdAt)
        .inMilliseconds /
        3600000.0;
    if (dtHours <= 0) continue;
    final avgPowerW = (sorted[i - 1].power + sorted[i].power) / 2.0;
    if (avgPowerW > 0) {
      wattHours += avgPowerW * dtHours;
    }
  }
  return (wattHours / 1000.0).clamp(0, double.infinity);
}

/// Energy consumed in [readingsInPeriod], optionally from a baseline sample
/// just before the period (e.g. last reading before local midnight).
double energyConsumedInPeriod(
  List<SensorReading> readingsInPeriod, {
  SensorReading? baseline,
}) {
  if (readingsInPeriod.isEmpty && baseline == null) return 0;

  final sorted = List<SensorReading>.from(readingsInPeriod)
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  if (sorted.isEmpty) {
    return 0;
  }

  if (sorted.length == 1) {
    if (baseline == null) return 0;
    final curr = sorted.first.energy;
    final prev = baseline.energy;
    return curr >= prev ? (curr - prev).clamp(0, double.infinity) : 0;
  }

  return sumEnergyConsumption(
    baseline != null ? [baseline, ...sorted] : sorted,
  );
}

/// Best-effort period kWh: PZEM register deltas, then power integration fallback.
double computePeriodKwh(
  List<SensorReading> readings, {
  SensorReading? baseline,
}) {
  if (readings.isEmpty && baseline == null) return 0;

  final registerKwh = energyConsumedInPeriod(readings, baseline: baseline);
  if (registerKwh > 0) return registerKwh;

  final merged = baseline != null ? [baseline, ...readings] : readings;
  return integratePowerToKwh(merged);
}

/// Energy consumed within a single day's readings (sorted ascending).
double sumEnergyForDay(List<SensorReading> dayReadings) {
  return computePeriodKwh(dayReadings);
}

/// Format kW for UI — extra precision when values are small.
String formatKw(double kw) {
  final abs = kw.abs();
  if (abs >= 100) return kw.toStringAsFixed(0);
  if (abs >= 10) return kw.toStringAsFixed(1);
  if (abs >= 1) return kw.toStringAsFixed(2);
  if (abs >= 0.01) return kw.toStringAsFixed(3);
  return kw.toStringAsFixed(4);
}

/// Format kWh for UI — extra precision when values are small.
String formatKwh(double kwh) {
  final abs = kwh.abs();
  if (abs >= 100) return kwh.toStringAsFixed(0);
  if (abs >= 10) return kwh.toStringAsFixed(1);
  if (abs >= 1) return kwh.toStringAsFixed(2);
  if (abs >= 0.01) return kwh.toStringAsFixed(3);
  return kwh.toStringAsFixed(4);
}

/// Cumulative kWh consumed through each reading (for today charts).
List<({DateTime time, double kwh})> cumulativePeriodKwhPoints(
  List<SensorReading> readings,
) {
  if (readings.isEmpty) return [];

  final sorted = List<SensorReading>.from(readings)
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  final points = <({DateTime time, double kwh})>[
    (time: sorted.first.createdAt, kwh: 0),
  ];
  var total = 0.0;
  for (var i = 1; i < sorted.length; i++) {
    total += computePeriodKwh([sorted[i - 1], sorted[i]]);
    points.add((time: sorted[i].createdAt, kwh: total));
  }
  return points;
}

/// Downsample readings for charts (keeps first/last and even steps).
List<SensorReading> downsampleReadingsForChart(
  List<SensorReading> readings, {
  int maxPoints = 120,
}) {
  if (readings.length <= maxPoints) return readings;

  final sorted = List<SensorReading>.from(readings)
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  final result = <SensorReading>[sorted.first];
  final step = (sorted.length - 1) / (maxPoints - 1);
  for (var i = 1; i < maxPoints - 1; i++) {
    result.add(sorted[(i * step).round()]);
  }
  result.add(sorted.last);
  return result;
}
