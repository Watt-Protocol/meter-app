import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/mining_event.dart';
import '../../../routing/app_router.dart';

class HistoryMintingList extends StatelessWidget {
  final List<MiningEvent> events;

  const HistoryMintingList({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.mintingActivity,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textMuted,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (events.isNotEmpty)
              TextButton(
                onPressed: () => context.push(AppRoutes.mintingActivity),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.gold,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  AppStrings.viewAll,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppDimensions.sm),
        if (events.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.lg),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(
              AppStrings.noMintingEvents,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...events.take(5).map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.sm),
                  child: MintingEventTile(
                    event: e,
                    onTap: () => context.push(
                      AppRoutes.miningDetail(e.id),
                      extra: e,
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}

/// Shared tappable row for minting events (history preview + activity list).
class MintingEventTile extends StatelessWidget {
  final MiningEvent event;
  final VoidCallback onTap;

  const MintingEventTile({
    super.key,
    required this.event,
    required this.onTap,
  });

  String _truncateHash(String? hash) {
    if (hash == null || hash.length < 12) return hash ?? '--';
    return '${hash.substring(0, 8)}…${hash.substring(hash.length - 4)}';
  }

  Color _statusColor() {
    if (event.isFailed) return AppColors.offline;
    if (event.isUserTransferConfirmed) return AppColors.online;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();
    final statusLabel = event.displayStatusLabel;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.md),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${event.kwh.toStringAsFixed(2)} kWh → '
                            '${event.userWattReceived.toStringAsFixed(2)} WATT',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusFull,
                            ),
                          ),
                          child: Text(
                            statusLabel,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.xs),
                    Text(
                      '${AppStrings.wattGrossMint}: ${event.wattGross.toStringAsFixed(2)} · '
                      '${AppStrings.cifContribution}: ${event.cifAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                    ),
                    Text(
                      AppDateUtils.formatFull(event.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                    ),
                    if (event.isUserTransferConfirmed) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${AppStrings.userMintTx}: ${_truncateHash(event.txHash)}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.gold.withValues(alpha: 0.85),
                              fontFamily: 'monospace',
                              fontSize: 10,
                            ),
                      ),
                    ],
                    if (event.isCifTransferConfirmed) ...[
                      Text(
                        '${AppStrings.cifMintTx}: ${_truncateHash(event.cifTxHash)}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontFamily: 'monospace',
                              fontSize: 10,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
