import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../data/providers/meters_providers.dart';
import '../../data/providers/sensor_providers.dart';
import '../dashboard/widgets/add_meter_sheet.dart';
import 'widgets/meter_list_card.dart';

/// Full list of user meters from Supabase `user_meters` + live status.
class MyMetersScreen extends ConsumerWidget {
  const MyMetersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metersAsync = ref.watch(userMetersProvider);
    final anyOnline = metersAsync.asData?.value.any((m) => m.isOnline) ?? false;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.gold,
          onRefresh: () async {
            ref.invalidate(userMetersProvider);
            ref.invalidate(latestReadingProvider);
            await ref.read(userMetersProvider.future);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.md,
                    AppDimensions.sm,
                    AppDimensions.md,
                    AppDimensions.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                            color: AppColors.textPrimary,
                          ),
                          Expanded(
                            child: Text(
                              AppStrings.myMeters,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                          _HeaderStatusPill(isOnline: anyOnline),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      Text(
                        'View your meters and whether each one is sending live readings.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                              height: 1.45,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              metersAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.gold),
                  ),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.lg),
                      child: Text(
                        'Could not load your meters.\nPull to refresh or check your internet connection.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ),
                data: (meters) => SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.md,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      ...meters.map(
                        (m) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppDimensions.md,
                          ),
                          child: MeterListCard(
                            meter: m,
                            onTap: () async {
                              await ref
                                  .read(selectedMeterDeviceIdProvider.notifier)
                                  .select(m.deviceId);
                              if (context.mounted) context.pop();
                            },
                          ),
                        ),
                      ),
                      AddMeterPlaceholder(
                        onTap: () => showAddMeterSheet(context, ref),
                      ),
                      const SizedBox(height: AppDimensions.md),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () => showAddMeterSheet(context, ref),
                          icon: const Icon(Icons.qr_code_scanner_rounded),
                          label: const Text('Add New Meter'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.xl),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderStatusPill extends StatelessWidget {
  final bool isOnline;

  const _HeaderStatusPill({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isOnline ? AppColors.online : AppColors.offline,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppDimensions.sm),
          Text(
            isOnline ? AppStrings.statusLive : AppStrings.statusOffline,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
