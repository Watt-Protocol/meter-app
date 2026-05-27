/// kWh shown in the app — aligned with [mining_events] and worker pending balance.
double consumptionDisplayKwh({
  required double meterKwh,
  required double mintedKwh,
  double pendingKwh = 0,
}) {
  final rewardsBasis = mintedKwh + pendingKwh;
  if (rewardsBasis > meterKwh) return rewardsBasis;
  return meterKwh;
}
