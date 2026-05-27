import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../data/models/mining_event.dart';
import '../../data/models/sensor_reading.dart';
import '../../data/models/user_profile.dart';
import '../../data/providers/meters_providers.dart';
import '../../data/providers/mining_providers.dart';
import '../../data/providers/sensor_providers.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/meter_chip_row.dart';
import 'widgets/recent_mint_card.dart';
import 'widgets/total_rewards_card.dart';
import 'widgets/todays_usage_card.dart';
import 'widgets/offline_meter_panel.dart';
import '../../../core/utils/date_utils.dart';
import 'widgets/metrics_carousel.dart';
import 'widgets/oscilloscope_card.dart';

/// Main dashboard — full-width rewards; live data hidden when offline.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readingAsync = ref.watch(latestReadingProvider);
    final connectivity = ref.watch(meterConnectivityProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final usageAsync = ref.watch(todayUsageProvider);
    final scopeAsync = ref.watch(oscilloscopeReadingsProvider);
    final latestMintAsync = ref.watch(latestMiningEventProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: readingAsync.when(
          loading: () => _buildScroll(
            ref,
            isMeterOnline: false,
            profileAsync: profileAsync,
            usageAsync: usageAsync,
            latestMintAsync: latestMintAsync,
            lastReadingAt: null,
            liveSection: _buildLoadingLive(),
          ),
          error: (error, stack) => _buildScroll(
            ref,
            isMeterOnline: false,
            profileAsync: profileAsync,
            usageAsync: usageAsync,
            latestMintAsync: latestMintAsync,
            lastReadingAt: null,
            liveSection: const OfflineMeterPanel(lastSeen: null),
          ),
          data: (reading) => RefreshIndicator(
            color: AppColors.gold,
            backgroundColor: AppColors.cardBg,
            onRefresh: () => _refresh(ref),
            child: _buildScroll(
              ref,
              isMeterOnline: connectivity == MeterConnectivity.live,
              profileAsync: profileAsync,
              usageAsync: usageAsync,
              latestMintAsync: latestMintAsync,
              lastReadingAt: reading?.createdAt,
              liveSection: _buildMeterSection(
                context,
                reading: reading,
                connectivity: connectivity,
                scopeAsync: scopeAsync,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refresh(WidgetRef ref) async {
    ref.read(sensorRepositoryProvider).clearDayCache();
    ref.invalidate(latestReadingProvider);
    ref.invalidate(userProfileProvider);
    ref.invalidate(todayUsageProvider);
    ref.invalidate(oscilloscopeReadingsProvider);
    ref.invalidate(userMetersProvider);
    ref.invalidate(latestMiningEventProvider);
    ref.invalidate(todayMiningSummaryProvider);
    await ref.read(todayUsageProvider.future);
  }

  Widget _buildScroll(
    WidgetRef ref, {
    required bool isMeterOnline,
    required AsyncValue<UserProfile?> profileAsync,
    required AsyncValue<TodayUsageStats> usageAsync,
    required AsyncValue<MiningEvent?> latestMintAsync,
    required DateTime? lastReadingAt,
    required Widget liveSection,
  }) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.md,
        AppDimensions.sm,
        AppDimensions.md,
        AppDimensions.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DashboardHeader(),
          const SizedBox(height: AppDimensions.md),
          const MeterChipRow(),
          const SizedBox(height: AppDimensions.md),
          profileAsync.when(
            skipLoadingOnReload: true,
            skipLoadingOnRefresh: true,
            loading: () => const TotalRewardsCard(isLoading: true),
            error: (_, _) => const TotalRewardsCard(),
            data: (profile) => TotalRewardsCard(profile: profile),
          ),
          const SizedBox(height: AppDimensions.md),
          latestMintAsync.when(
            skipLoadingOnReload: true,
            skipLoadingOnRefresh: true,
            loading: () => const RecentMintCard(isLoading: true),
            error: (_, _) => const RecentMintCard(),
            data: (event) => RecentMintCard(event: event),
          ),
          const SizedBox(height: AppDimensions.md),
          usageAsync.when(
            skipLoadingOnReload: true,
            loading: () => const TodaysUsageCard(isLoading: true),
            error: (_, _) => const TodaysUsageCard(),
            data: (stats) => TodaysUsageCard(
              stats: stats,
              lastReadingAt: lastReadingAt,
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          liveSection,
        ],
      ),
    );
  }

  Widget _buildMeterSection(
    BuildContext context, {
    required SensorReading? reading,
    required MeterConnectivity connectivity,
    required AsyncValue<List<double>> scopeAsync,
  }) {
    if (reading == null) {
      return const OfflineMeterPanel(lastSeen: null);
    }

    final showLiveOscilloscope = connectivity == MeterConnectivity.live;

    if (connectivity == MeterConnectivity.stale) {
      return Center(
        child: Text(
          AppDateUtils.lastReadingAgo(reading.createdAt),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
              ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MetricsCarousel(reading: reading, isLive: true),
        const SizedBox(height: AppDimensions.md),
        if (showLiveOscilloscope)
          scopeAsync.when(
            skipLoadingOnReload: true,
            skipLoadingOnRefresh: true,
            loading: () => const OscilloscopeCard(
              powerSamples: [],
              isLoading: true,
              compact: true,
            ),
            error: (_, _) => const OscilloscopeCard(
              powerSamples: [],
              compact: true,
            ),
            data: (samples) => OscilloscopeCard(
              powerSamples: samples,
              compact: true,
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingLive() {
    return Shimmer.fromColors(
      baseColor: AppColors.cardBg,
      highlightColor: AppColors.surfaceDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 14,
            width: 100,
            margin: const EdgeInsets.only(bottom: AppDimensions.sm),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              separatorBuilder: (_, _) => const SizedBox(width: AppDimensions.sm),
              itemBuilder: (_, _) => Container(
                width: 108,
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
