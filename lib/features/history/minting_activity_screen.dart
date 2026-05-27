import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/mining_event.dart';
import '../../data/providers/mining_providers.dart';
import '../../routing/app_router.dart';
import 'widgets/mining_activity_filters.dart';
import 'widgets/history_minting_list.dart';

/// Full-screen minting activity list with filters and navigation to detail.
class MintingActivityScreen extends ConsumerWidget {
  const MintingActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(miningEventsProvider);
    final filtered = ref.watch(filteredMiningEventsProvider);
    final summary = ref.watch(miningSummaryProvider);

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
          AppStrings.mintingActivityTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.gold,
        onRefresh: () => ref.read(miningEventsProvider.notifier).refresh(),
        child: eventsAsync.when(
          loading: () => _buildLoading(),
          error: (_, _) => _buildError(context, ref),
          data: (_) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppDimensions.md),
              children: [
                _SummaryBanner(summary: summary, count: filtered.length),
                const SizedBox(height: AppDimensions.md),
                const MiningActivityFilters(),
                const SizedBox(height: AppDimensions.lg),
                if (filtered.isEmpty)
                  _buildEmptyFilters(context)
                else
                  ...filtered.map(
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
                const SizedBox(height: AppDimensions.xl),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Shimmer.fromColors(
      baseColor: AppColors.cardBg,
      highlightColor: AppColors.surfaceDark,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.md),
        itemCount: 6,
        itemBuilder: (_, _) => Container(
          height: 88,
          margin: const EdgeInsets.only(bottom: AppDimensions.sm),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColors.offline, size: 48),
          const SizedBox(height: AppDimensions.md),
          Text(AppStrings.connectionError),
          const SizedBox(height: AppDimensions.lg),
          ElevatedButton(
            onPressed: () {
              ref.read(miningEventsProvider.notifier).refresh();
            },
            child: const Text(AppStrings.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFilters(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        AppStrings.noMatchingEvents,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textMuted,
            ),
      ),
    );
  }
}

class _SummaryBanner extends StatelessWidget {
  final MiningSummary summary;
  final int count;

  const _SummaryBanner({required this.summary, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Text(
                  '${summary.totalWattEarned.toStringAsFixed(1)} WATT',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  '${summary.totalKwh.toStringAsFixed(1)} kWh · $count events',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
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
