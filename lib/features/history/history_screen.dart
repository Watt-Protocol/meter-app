import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_dimensions.dart';
import '../../data/providers/history_display_providers.dart';
import '../../data/providers/meters_providers.dart';
import '../../data/providers/mining_providers.dart';
import '../../data/providers/sensor_providers.dart';
import '../dashboard/widgets/dashboard_header.dart';
import 'widgets/filter_chips.dart';
import 'widgets/history_energy_card.dart';
import 'widgets/history_economy_card.dart';
import 'widgets/history_meter_selector.dart';
import 'widgets/history_metric_tiles.dart';
import 'widgets/history_minting_list.dart';

/// Energy history: consumption from sensors + minting from mining_events.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(readingsHistoryProvider);
    final statsAsync = ref.watch(historyStatsWithMiningProvider);
    final miningEventsAsync = ref.watch(miningEventsProvider);
    final miningSummary = ref.watch(miningSummaryProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final filter = ref.watch(dateRangeFilterProvider);
    final metersAsync = ref.watch(userMetersProvider);
    final selectedId = ref.watch(selectedMeterDeviceIdProvider);

    final meterLabel = metersAsync.whenOrNull(
          data: (meters) {
            final match =
                meters.where((m) => m.deviceId == selectedId).firstOrNull;
            return match?.label ?? selectedId;
          },
        ) ??
        selectedId;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.gold,
          onRefresh: () => _refresh(ref),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.md,
                  AppDimensions.md,
                  AppDimensions.md,
                  0,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const DashboardHeader(),
                    const SizedBox(height: AppDimensions.lg),
                    Text(
                      AppStrings.energyHistory,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    const HistoryMeterSelector(),
                    const SizedBox(height: AppDimensions.md),
                    const FilterChips(),
                    const SizedBox(height: AppDimensions.lg),
                    Text(
                      AppStrings.energyConsumption,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: AppDimensions.sm),
                  ]),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.md,
                ),
                sliver: historyAsync.when(
                  loading: () => SliverToBoxAdapter(child: _buildLoadingState()),
                  error: (error, _) =>
                      SliverToBoxAdapter(child: _buildErrorState(context, ref)),
                  data: (readings) {
                    return SliverList(
                      delegate: SliverChildListDelegate([
                        if (readings.isEmpty)
                          _buildEmptyState(context, meterLabel)
                        else ...[
                          statsAsync.when(
                            loading: () => _buildStatsLoading(),
                            error: (_, _) => const SizedBox.shrink(),
                            data: (stats) => HistoryEnergyCard(
                              stats: stats,
                              readings: readings,
                              filter: filter,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.md),
                          statsAsync.when(
                            loading: () => _buildStatsLoading(height: 100),
                            error: (_, _) => const SizedBox.shrink(),
                            data: (stats) => HistoryMetricTiles(stats: stats),
                          ),
                        ],
                        const SizedBox(height: AppDimensions.lg),
                        profileAsync.when(
                          loading: () => HistoryEconomyCard(
                            summary: miningSummary,
                            isLoading: true,
                          ),
                          error: (_, _) =>
                              HistoryEconomyCard(summary: miningSummary),
                          data: (profile) => HistoryEconomyCard(
                            summary: miningSummary,
                            profile: profile,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.lg),
                        miningEventsAsync.when(
                          loading: () => _buildStatsLoading(height: 80),
                          error: (_, _) => const HistoryMintingList(events: []),
                          data: (events) => HistoryMintingList(events: events),
                        ),
                        const SizedBox(height: AppDimensions.xl),
                      ]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refresh(WidgetRef ref) async {
    ref.read(sensorRepositoryProvider).clearDayCache();
    ref.invalidate(todayUsageProvider);
    ref.invalidate(periodReadingsHistoryProvider);
    ref.invalidate(periodHistoryStatsProvider);
    await ref.read(miningEventsProvider.notifier).refresh();
    ref.invalidate(userProfileProvider);
    await ref.read(todayUsageProvider.future);
  }

  Widget _buildStatsLoading({double height = 280}) {
    return Shimmer.fromColors(
      baseColor: AppColors.cardBg,
      highlightColor: AppColors.surfaceDark,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        _buildStatsLoading(),
        const SizedBox(height: AppDimensions.md),
        _buildStatsLoading(height: 100),
        const SizedBox(height: AppDimensions.md),
        _buildStatsLoading(height: 140),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, String meterLabel) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.lg),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.show_chart_rounded,
              size: 48,
              color: AppColors.mutedGold,
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          Text(
            AppStrings.noReadingsForMeter,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            meterLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.gold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.offline),
          const SizedBox(height: AppDimensions.md),
          Text(
            AppStrings.connectionError,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppDimensions.lg),
          ElevatedButton.icon(
            onPressed: () => _refresh(ref),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text(AppStrings.retry),
          ),
        ],
      ),
    );
  }
}
