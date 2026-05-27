import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/sensor_reading.dart';
import 'metric_tile.dart';

/// Horizontally scrollable live metric tiles (compact).
class MetricsCarousel extends StatelessWidget {
  final SensorReading reading;
  final bool isLive;

  const MetricsCarousel({
    super.key,
    required this.reading,
    this.isLive = false,
  });

  static const _tileWidth = 108.0;
  static const _tileHeight = 104.0;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _MetricData(Icons.bolt_rounded, AppStrings.voltage,
          reading.voltage.toStringAsFixed(0), AppStrings.unitVoltage),
      _MetricData(Icons.waves_rounded, AppStrings.current,
          reading.current.toStringAsFixed(2), AppStrings.unitCurrent),
      _MetricData(Icons.offline_bolt_rounded, AppStrings.power,
          reading.power.toStringAsFixed(0), AppStrings.unitPower),
      _MetricData(Icons.battery_charging_full_rounded, AppStrings.energy,
          reading.energy.toStringAsFixed(2), AppStrings.unitEnergy),
      _MetricData(Icons.grid_view_rounded, AppStrings.frequency,
          reading.frequency.toStringAsFixed(0), AppStrings.unitFrequency),
      _MetricData(Icons.bar_chart_rounded, 'P. Factor',
          reading.powerFactor.toStringAsFixed(2), 'φ'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppDimensions.xs),
          child: Text(
            isLive ? 'LIVE METRICS' : 'LAST READING',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        SizedBox(
          height: _tileHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tiles.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppDimensions.sm),
            itemBuilder: (context, i) {
              final t = tiles[i];
              return SizedBox(
                width: _tileWidth,
                child: MetricTile(
                  icon: t.icon,
                  label: t.label,
                  value: t.value,
                  unit: t.unit,
                  compact: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MetricData {
  final IconData icon;
  final String label;
  final String value;
  final String unit;

  const _MetricData(this.icon, this.label, this.value, this.unit);
}
