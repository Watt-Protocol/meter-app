import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/mining_event.dart';
import '../../../data/models/user_profile.dart';

class HistoryEconomyCard extends StatelessWidget {
  final MiningSummary summary;
  final UserProfile? profile;
  final bool isLoading;

  const HistoryEconomyCard({
    super.key,
    required this.summary,
    this.profile,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final onChain = profile?.creditedWatt ?? 0;
    final pending = profile?.pendingWatt ?? 0;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.economyRewards,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppDimensions.md),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.md),
                child: CircularProgressIndicator(
                  color: AppColors.gold,
                  strokeWidth: 2,
                ),
              ),
            )
          else ...[
            Text(
              '${summary.totalUserWatt.toStringAsFixed(1)} WATT',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppDimensions.xs),
            Text(
              '${AppStrings.periodMinted}: ${summary.totalKwh.toStringAsFixed(1)} kWh · '
              '${AppStrings.userWattReceived} ${summary.totalUserWatt.toStringAsFixed(1)} WATT',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
            if (summary.totalWattGross > 0) ...[
              const SizedBox(height: AppDimensions.xs),
              Text(
                '${AppStrings.wattGrossMint}: ${summary.totalWattGross.toStringAsFixed(1)} WATT',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
            if (summary.totalCifAmount > 0) ...[
              const SizedBox(height: AppDimensions.xs),
              Text(
                '${AppStrings.cifContribution}: ${summary.totalCifAmount.toStringAsFixed(2)} WATT',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
            Text(
              AppStrings.walletTxCountHint,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
            ),
            const SizedBox(height: AppDimensions.md),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: AppDimensions.md),
            Row(
              children: [
                Expanded(
                  child: _SubMetric(
                    label: AppStrings.yourWalletBalance,
                    value: onChain.toStringAsFixed(1),
                  ),
                ),
                Expanded(
                  child: _SubMetric(
                    label: AppStrings.accruingKwh,
                    value: pending.toStringAsFixed(1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            Row(
              children: [
                _StatusChip(
                  label:
                      '${summary.countConfirmed} ${AppStrings.statusConfirmed}',
                  color: AppColors.online,
                ),
                const SizedBox(width: AppDimensions.sm),
                _StatusChip(
                  label:
                      '${summary.countPending} ${AppStrings.statusPending}',
                  color: AppColors.warning,
                ),
                if (summary.countFailed > 0) ...[
                  const SizedBox(width: AppDimensions.sm),
                  _StatusChip(
                    label:
                        '${summary.countFailed} ${AppStrings.statusFailed}',
                    color: AppColors.offline,
                  ),
                ],
              ],
            ),
            if ((profile?.lifetimeCifContributed ?? 0) > 0) ...[
              const SizedBox(height: AppDimensions.sm),
              Text(
                '${AppStrings.lifetimeCifFromYou}: '
                '${profile!.lifetimeCifContributed.toStringAsFixed(2)} WATT',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _SubMetric extends StatelessWidget {
  final String label;
  final String value;

  const _SubMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textMuted,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
      ),
    );
  }
}
