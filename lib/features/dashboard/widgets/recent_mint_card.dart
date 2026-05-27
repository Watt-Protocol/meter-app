import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/mining_event.dart';
import '../../../routing/app_router.dart';
import '../../../routing/tab_navigation_provider.dart';

class RecentMintCard extends ConsumerWidget {
  final MiningEvent? event;
  final bool isLoading;

  const RecentMintCard({
    super.key,
    this.event,
    this.isLoading = false,
  });

  void _openHistoryTab(BuildContext context, WidgetRef ref) {
    ref.read(tabNavigationProvider.notifier).setIndices(0, 1);
    context.go(AppRoutes.history);
  }

  void _openMintDetail(BuildContext context) {
    if (event == null) return;
    context.push(AppRoutes.miningDetail(event!.id), extra: event);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.recentMint,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textMuted,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              TextButton.icon(
                onPressed: () => _openHistoryTab(context, ref),
                icon: const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.gold,
                ),
                label: Text(
                  AppStrings.viewHistory,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.gold,
                      ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.sm,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          if (isLoading)
            const SizedBox(
              height: 40,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.gold,
                  strokeWidth: 2,
                ),
              ),
            )
          else if (event == null)
            Text(
              AppStrings.noMintingEvents,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
            )
          else
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openMintDetail(context),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppDimensions.xs),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.sm),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.monetization_on_rounded,
                          color: AppColors.gold,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${event!.userWattReceived.toStringAsFixed(2)} \$WATT',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            Text(
                              '${event!.kwh.toStringAsFixed(2)} kWh · '
                              'CIF ${event!.cifAmount.toStringAsFixed(2)} · '
                              '${AppDateUtils.timeAgo(event!.createdAt)}',
                              style:
                                  Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.textMuted,
                                      ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        event!.isFailed
                            ? Icons.cancel_rounded
                            : event!.isUserTransferConfirmed
                                ? Icons.check_circle_rounded
                                : Icons.schedule_rounded,
                        color: event!.isFailed
                            ? AppColors.offline
                            : event!.isUserTransferConfirmed
                                ? AppColors.online
                                : AppColors.warning,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
