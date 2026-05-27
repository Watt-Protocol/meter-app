import 'package:flutter_test/flutter_test.dart';
import 'package:watt_smart_meter/core/utils/energy_utils.dart';
import 'package:watt_smart_meter/data/models/sensor_reading.dart';

SensorReading _reading(DateTime at, double energyKwh) {
  return SensorReading(
    id: '1',
    createdAt: at,
    voltage: 220,
    current: 0.1,
    power: 10,
    energy: energyKwh,
    frequency: 50,
    powerFactor: 1,
    deviceId: 'esp32_001',
  );
}

void main() {
  test('computePeriodKwh uses baseline before period start', () {
    final t0 = DateTime(2026, 5, 25, 8);
    final t1 = DateTime(2026, 5, 25, 12);
    final baseline = _reading(t0, 10);
    final inPeriod = [_reading(t1, 15)];

    final kwh = computePeriodKwh(inPeriod, baseline: baseline);
    expect(kwh, closeTo(5, 0.001));
  });

  test('sumEnergyConsumption without baseline under-counts single window', () {
    final t0 = DateTime(2026, 5, 25, 8);
    final t1 = DateTime(2026, 5, 25, 12);
    final readings = [_reading(t0, 10), _reading(t1, 15)];

    expect(sumEnergyConsumption(readings), closeTo(5, 0.001));
    expect(computePeriodKwh(readings), closeTo(5, 0.001));
  });
}
