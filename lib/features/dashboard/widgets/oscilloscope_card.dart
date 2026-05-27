import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

class OscilloscopeCard extends StatelessWidget {
  final List<double> powerSamples;
  final bool isLoading;
  final bool compact;

  const OscilloscopeCard({
    super.key,
    required this.powerSamples,
    this.isLoading = false,
    this.compact = true,
  });

  @override
  Widget build(BuildContext context) {
    final samples = powerSamples.isEmpty
        ? List<double>.filled(24, 0)
        : _padTo24(powerSamples);

    final maxPower = samples.reduce((a, b) => a > b ? a : b);
    final maxY = maxPower > 0 ? maxPower * 1.2 : 100.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.md,
        AppDimensions.md,
        AppDimensions.md,
        AppDimensions.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REAL-TIME OSCILLOSCOPE',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppDimensions.md),
          SizedBox(
            height: compact ? 88 : 120,
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.gold,
                      strokeWidth: 2,
                    ),
                  )
                : BarChart(
                    BarChartData(
                      maxY: maxY,
                      minY: 0,
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      barGroups: List.generate(samples.length, (i) {
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: samples[i],
                              color: AppColors.gold.withValues(
                                alpha: 0.35 + (samples[i] / maxY) * 0.65,
                              ),
                              width: compact ? 4 : 6,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(3),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<double> _padTo24(List<double> input) {
    if (input.length >= 24) return input.sublist(input.length - 24);
    final pad = List<double>.filled(24 - input.length, 0);
    return [...pad, ...input];
  }
}
