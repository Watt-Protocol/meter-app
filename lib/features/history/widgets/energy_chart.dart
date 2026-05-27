import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/energy_utils.dart';
import '../../../data/models/sensor_reading.dart';
import '../../../data/providers/sensor_providers.dart';

class _ChartPoint {
  final DateTime time;
  final double value;

  const _ChartPoint({required this.time, required this.value});
}

/// Line chart for energy (kWh) or power (kW) over time with gold gradient.
class EnergyChart extends StatelessWidget {
  final List<SensorReading> readings;
  final DateRangeFilter filter;
  final HistoryMetricFilter metricFilter;
  final bool compact;

  const EnergyChart({
    super.key,
    required this.readings,
    required this.filter,
    required this.metricFilter,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return const SizedBox.shrink();
    }

    final points = _buildChartPoints();
    if (points.isEmpty) return const SizedBox.shrink();

    final spots = points
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.value))
        .toList();
    final minY = _getMinY(points);
    final maxY = _getMaxY(points);
    final chartHeight = compact ? 200.0 : 280.0;
    final unitLabel =
        metricFilter == HistoryMetricFilter.energy ? 'kWh' : 'kW';

    final chart = LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _getGridInterval(minY, maxY),
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.divider,
            strokeWidth: 0.5,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: !compact,
              reservedSize: compact ? 0 : 40,
              getTitlesWidget: (value, meta) {
                if (compact) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: _getBottomInterval(points.length),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= points.length) {
                  return const SizedBox.shrink();
                }
                final dt = points[index].time;
                final label = switch (filter) {
                  DateRangeFilter.today => AppDateUtils.formatChartTime(dt),
                  DateRangeFilter.last7Days =>
                    AppDateUtils.formatChartWeekday(dt),
                  DateRangeFilter.last30Days => AppDateUtils.formatChartDay(dt),
                };
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (points.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => AppColors.cardBgElevated,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                final point = index < points.length ? points[index] : null;
                final time = point != null
                    ? AppDateUtils.formatFull(point.time)
                    : '';
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(2)} $unitLabel\n$time',
                  const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppColors.gold,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: points.length <= 14,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: AppColors.gold,
                  strokeWidth: 1.5,
                  strokeColor: AppColors.scaffoldBg,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.gold.withValues(alpha: 0.3),
                  AppColors.gold.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );

    if (compact) {
      return SizedBox(
        height: chartHeight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.sm,
            AppDimensions.sm,
            AppDimensions.sm,
            AppDimensions.xs,
          ),
          child: chart,
        ),
      );
    }

    return Container(
      height: chartHeight,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.sm,
        AppDimensions.lg,
        AppDimensions.md,
        AppDimensions.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: chart,
    );
  }

  List<_ChartPoint> _buildChartPoints() {
    if (filter == DateRangeFilter.today) {
      final chartReadings = downsampleReadingsForChart(readings);
      if (metricFilter == HistoryMetricFilter.energy) {
        return cumulativePeriodKwhPoints(chartReadings)
            .map(
              (p) => _ChartPoint(time: p.time, value: p.kwh),
            )
            .toList();
      }
      return chartReadings
          .map(
            (r) => _ChartPoint(
              time: r.createdAt,
              value: r.power / 1000,
            ),
          )
          .toList();
    }
    return _aggregateByDay(readings);
  }

  List<_ChartPoint> _aggregateByDay(List<SensorReading> readings) {
    final byDay = <String, List<SensorReading>>{};
    for (final r in readings) {
      final key =
          '${r.createdAt.year}-${r.createdAt.month}-${r.createdAt.day}';
      byDay.putIfAbsent(key, () => []).add(r);
    }

    final keys = byDay.keys.toList()..sort();
    final points = <_ChartPoint>[];

    for (final key in keys) {
      final dayReadings = byDay[key]!
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      final dayStart = dayReadings.first.createdAt;

      double value;
      if (metricFilter == HistoryMetricFilter.energy) {
        value = sumEnergyForDay(dayReadings);
      } else {
        value = dayReadings
                .map((r) => r.power)
                .reduce((a, b) => a > b ? a : b) /
            1000;
      }

      points.add(_ChartPoint(time: dayStart, value: value.clamp(0, double.infinity)));
    }

    return points;
  }

  double _getMinY(List<_ChartPoint> points) {
    if (points.isEmpty) return 0;
    final min = points.map((p) => p.value).reduce((a, b) => a < b ? a : b);
    return (min * 0.9).clamp(0, double.infinity);
  }

  double _getMaxY(List<_ChartPoint> points) {
    if (points.isEmpty) return 1;
    final max = points.map((p) => p.value).reduce((a, b) => a > b ? a : b);
    return max * 1.1 + 0.001;
  }

  double _getGridInterval(double minY, double maxY) {
    final range = maxY - minY;
    if (range <= 0) return 1;
    return (range / 4).clamp(0.001, double.infinity);
  }

  double _getBottomInterval(int length) {
    if (length <= 7) return 1;
    return (length / 6).roundToDouble();
  }
}
