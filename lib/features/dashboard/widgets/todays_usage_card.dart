import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/energy_utils.dart';
import '../../../data/models/user_profile.dart';

class TodaysUsageCard extends StatelessWidget {
  final TodayUsageStats? stats;
  final bool isLoading;
  final bool compact;
  final DateTime? lastReadingAt;

  const TodaysUsageCard({
    super.key,
    this.stats,
    this.isLoading = false,
    this.compact = false,
    this.lastReadingAt,
  });

  @override
  Widget build(BuildContext context) {
    final kwh = stats?.todayKwh ?? 0;

    return Container(
      height: compact ? double.infinity : null,
      padding: EdgeInsets.all(compact ? AppDimensions.md : AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(
              compact ? AppDimensions.sm : AppDimensions.sm + 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bolt_rounded,
              color: AppColors.gold,
              size: compact ? 20 : 24,
            ),
          ),
          SizedBox(width: compact ? AppDimensions.sm : AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.todaysInsight,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                        fontSize: compact ? 11 : null,
                      ),
                ),
                if (isLoading)
                  SizedBox(
                    height: compact ? 20 : 24,
                    width: compact ? 20 : 24,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.gold,
                    ),
                  )
                else
                  Text(
                    '${formatKwh(kwh)} kWh',
                    style: (compact
                            ? Theme.of(context).textTheme.titleMedium
                            : Theme.of(context).textTheme.titleLarge)
                        ?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                if (stats?.statusHint != null && !isLoading)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      stats!.statusHint!,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                            fontSize: compact ? 10 : 11,
                          ),
                    ),
                  )
                else if (lastReadingAt != null && !isLoading)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      AppDateUtils.lastReadingAgo(lastReadingAt!),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
