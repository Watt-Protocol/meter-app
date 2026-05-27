import 'package:flutter_test/flutter_test.dart';
import 'package:watt_smart_meter/core/utils/consumption_display.dart';

void main() {
  test('uses minted plus pending when higher than meter', () {
    expect(
      consumptionDisplayKwh(
        meterKwh: 0.005,
        mintedKwh: 61,
        pendingKwh: 0.1,
      ),
      closeTo(61.1, 0.001),
    );
  });

  test('falls back to meter when no minting', () {
    expect(
      consumptionDisplayKwh(meterKwh: 2.5, mintedKwh: 0, pendingKwh: 0),
      2.5,
    );
  });
}
