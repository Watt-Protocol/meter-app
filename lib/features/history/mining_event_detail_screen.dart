import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/mining_event.dart';
import '../../data/providers/mining_providers.dart';
import '../../data/providers/sensor_providers.dart';
import 'widgets/copyable_detail_row.dart';

/// Full detail view for a single mining_events row (user + CIF legs).
class MiningEventDetailScreen extends ConsumerWidget {
  final int eventId;
  final MiningEvent? initialEvent;

  const MiningEventDetailScreen({
    super.key,
    required this.eventId,
    this.initialEvent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cached = ref.watch(miningEventByIdProvider(eventId));
    final event = initialEvent ?? cached;
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppStrings.activityDetail,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      body: event == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline, color: AppColors.textMuted, size: 48),
                  const SizedBox(height: AppDimensions.md),
                  Text(
                    'Event not found',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go back'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeroCard(event: event),
                  const SizedBox(height: AppDimensions.lg),
                  profileAsync.when(
                    data: (profile) => CopyableDetailRow(
                      label: AppStrings.walletAddress,
                      value: profile?.walletAddress ?? '--',
                      monospace: true,
                    ),
                    loading: () => const CopyableDetailRow(
                      label: AppStrings.walletAddress,
                      value: '…',
                    ),
                    error: (_, _) => const CopyableDetailRow(
                      label: AppStrings.walletAddress,
                      value: '--',
                    ),
                  ),
                  CopyableDetailRow(
                    label: AppStrings.eventId,
                    value: '${event.id}',
                    canCopy: false,
                  ),
                  CopyableDetailRow(
                    label: AppStrings.dateTime,
                    value: AppDateUtils.formatFull(event.createdAt),
                    canCopy: false,
                  ),
                  CopyableDetailRow(
                    label: AppStrings.status,
                    value: event.displayStatusLabel.toUpperCase(),
                    canCopy: false,
                  ),
                  CopyableDetailRow(
                    label: AppStrings.kwhMinted,
                    value: '${event.kwh.toStringAsFixed(3)} kWh',
                    canCopy: false,
                  ),
                  CopyableDetailRow(
                    label: AppStrings.wattGrossMint,
                    value: '${event.wattGross.toStringAsFixed(3)} WATT',
                    canCopy: false,
                  ),
                  CopyableDetailRow(
                    label: AppStrings.userWattReceived,
                    value: '${event.userWattReceived.toStringAsFixed(3)} WATT',
                    canCopy: false,
                  ),
                  CopyableDetailRow(
                    label: AppStrings.userTxStatus,
                    value: event.userTxStatus.toUpperCase(),
                    canCopy: false,
                  ),
                  CopyableDetailRow(
                    label: AppStrings.userMintTx,
                    value: event.txHash ?? '--',
                    monospace: true,
                    canCopy: event.txHash != null,
                  ),
                  CopyableDetailRow(
                    label: AppStrings.cifContribution,
                    value: '${event.cifAmount.toStringAsFixed(4)} WATT',
                    canCopy: false,
                  ),
                  CopyableDetailRow(
                    label: AppStrings.cifTxStatus,
                    value: event.cifTxStatus.toUpperCase(),
                    canCopy: false,
                  ),
                  CopyableDetailRow(
                    label: AppStrings.cifMintTx,
                    value: event.cifTxHash ?? '--',
                    monospace: true,
                    canCopy: event.cifTxHash != null,
                  ),
                ],
              ),
            ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final MiningEvent event;

  const _HeroCard({required this.event});

  Color _statusColor() {
    if (event.isFailed) return AppColors.offline;
    if (event.isUserTransferConfirmed) return AppColors.online;
    return AppColors.warning;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();
    final statusLabel = event.displayStatusLabel;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.monetization_on_rounded,
              color: AppColors.gold,
              size: 40,
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            '${event.userWattReceived.toStringAsFixed(2)} WATT',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            '${AppStrings.userWattReceived} · ${event.kwh.toStringAsFixed(2)} kWh',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            '${AppStrings.wattGrossMint} ${event.wattGross.toStringAsFixed(2)} · '
            '${AppStrings.cifContribution} ${event.cifAmount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
          const SizedBox(height: AppDimensions.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.md,
              vertical: AppDimensions.xs,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              border: Border.all(color: statusColor.withValues(alpha: 0.4)),
            ),
            child: Text(
              statusLabel,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
