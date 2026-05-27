import '../../core/utils/consumption_display.dart';

/// Aggregated sensor stats for the history screen over the selected date range.
class HistoryStats {
  /// kWh from PZEM register deltas (and power integration fallback).
  final double periodKwh;

  /// kWh summed from [mining_events] in the same period (whole-kWh payouts).
  final double mintedKwh;

  /// Fractional kWh not yet minted ([waitlist_users.pending_watt]).
  final double pendingKwh;

  final double percentVsPriorPeriod;
  final double peakPowerKw;
  final double uptimePercent;

  const HistoryStats({
    required this.periodKwh,
    this.mintedKwh = 0,
    this.pendingKwh = 0,
    required this.percentVsPriorPeriod,
    required this.peakPowerKw,
    required this.uptimePercent,
  });

  bool get hasComparison => percentVsPriorPeriod.isFinite;

  /// Primary kWh headline — matches minting (minted + pending), else meter.
  double get displayKwh => consumptionDisplayKwh(
        meterKwh: periodKwh,
        mintedKwh: mintedKwh,
        pendingKwh: pendingKwh,
      );
}
