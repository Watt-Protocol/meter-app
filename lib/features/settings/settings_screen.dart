import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_dimensions.dart';
import '../../data/providers/app_preferences_providers.dart';
import '../../data/providers/auth_providers.dart';
import '../../data/providers/meters_providers.dart';
import '../../data/providers/sensor_providers.dart';
import '../../routing/app_router.dart';
import '../dashboard/widgets/add_meter_sheet.dart';
import '../dashboard/widgets/total_rewards_card.dart';
import 'widgets/settings_info_row.dart';
import 'widgets/settings_nav_row.dart';
import 'widgets/settings_section_header.dart';
import 'widgets/device_id_input.dart';

/// Settings screen matching mockup: meters, display, account, wallet, notifications.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(meterConnectivityProvider);
    final email = ref.watch(currentUserEmailProvider) ?? 'Unknown';
    final profileAsync = ref.watch(userProfileProvider);
    final metersAsync = ref.watch(userMetersProvider);
    final notificationsOn = ref.watch(notificationsEnabledProvider);
    final highVoltageOn = ref.watch(highVoltageAlertProvider);
    final staleMinutes = ref.watch(staleDataMinutesProvider);
    final walletSubtitle = profileAsync.whenOrNull(
          data: (p) => p?.walletAddress != null && p!.walletAddress!.isNotEmpty
              ? truncateWallet(p.walletAddress)
              : AppStrings.walletSettingsSubtitle,
        ) ??
        AppStrings.walletSettingsSubtitle;
    final notificationsSubtitle = notificationsOn
        ? '$staleMinutes min · ${highVoltageOn ? "High voltage on" : "High voltage off"}'
        : AppStrings.notificationsSettingsSubtitle;
    final themeMode = ref.watch(themeModeProvider);
    final defaultScreen = ref.watch(defaultScreenProvider);

    final meterCount = metersAsync.whenOrNull(data: (m) => m.length) ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.scaffoldBg : Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.md,
            AppDimensions.md,
            AppDimensions.md,
            AppDimensions.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SettingsHeader(connectivity: connectivity),
              const SizedBox(height: AppDimensions.lg),

              const SettingsSectionHeader(title: AppStrings.metersAndDevices),
              SettingsCard(
                goldAccentBorder: true,
                child: Column(
                  children: [
                    SettingsNavRow(
                      icon: Icons.electric_meter_rounded,
                      title: '${AppStrings.myMeters} ($meterCount)',
                      subtitle: AppStrings.activeMonitoring,
                      onTap: () => context.push(AppRoutes.meters),
                    ),
                    const SettingsRowDivider(),
                    SettingsNavRow(
                      icon: Icons.add_rounded,
                      title: AppStrings.addNewMeter,
                      iconStyle: SettingsNavIconStyle.squareGold,
                      onTap: () => showAddMeterSheet(context, ref),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.lg),
              SettingsCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.meterCode,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.meterCodeHint,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                      ),
                      const SizedBox(height: AppDimensions.sm),
                      const DeviceIdInput(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.lg),
              SettingsCard(
                child: Column(
                  children: [
                    SettingsNavRow(
                      icon: Icons.account_balance_wallet_outlined,
                      title: AppStrings.walletSettingsTitle,
                      subtitle: walletSubtitle,
                      onTap: () => context.push(AppRoutes.walletSettings),
                    ),
                    const SettingsRowDivider(),
                    SettingsNavRow(
                      icon: Icons.notifications_outlined,
                      title: AppStrings.notificationsSettingsTitle,
                      subtitle: notificationsSubtitle,
                      onTap: () =>
                          context.push(AppRoutes.notificationsSettings),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.lg),
              const SettingsSectionHeader(title: AppStrings.display),
              SettingsCard(
                child: SettingsNavRow(
                  icon: Icons.palette_outlined,
                  title: AppStrings.displaySettings,
                  subtitle:
                      '${_themeLabel(themeMode)} · ${_defaultScreenLabel(defaultScreen)}',
                  onTap: () => context.push(AppRoutes.displaySettings),
                ),
              ),

              const SizedBox(height: AppDimensions.lg),
              const SettingsSectionHeader(title: AppStrings.account),
              SettingsCard(
                child: profileAsync.when(
                  loading: () => Column(
                    children: [
                      SettingsAccountRow(
                        icon: Icons.email_outlined,
                        label: AppStrings.email,
                        value: email,
                      ),
                      const SettingsRowDivider(),
                      const SettingsReferralRow(),
                    ],
                  ),
                  error: (_, _) => Column(
                    children: [
                      SettingsAccountRow(
                        icon: Icons.email_outlined,
                        label: AppStrings.email,
                        value: email,
                      ),
                      const SettingsRowDivider(),
                      const SettingsReferralRow(),
                    ],
                  ),
                  data: (profile) => Column(
                    children: [
                      SettingsAccountRow(
                        icon: Icons.email_outlined,
                        label: AppStrings.email,
                        value: email,
                      ),
                      const SettingsRowDivider(),
                      SettingsReferralRow(
                        referralLink: profile?.referralLink,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.xl),
              OutlinedButton.icon(
                onPressed: () => _logout(context, ref),
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: Text(AppStrings.signOut),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF5F5F),
                  side: BorderSide(
                    color: isDark ? AppColors.inputBorder : AppColors.dividerLight,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _themeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.light => AppStrings.themeLight,
        ThemeMode.system => AppStrings.themeSystem,
        ThemeMode.dark => AppStrings.themeDark,
      };

  String _defaultScreenLabel(DefaultScreen screen) => switch (screen) {
        DefaultScreen.dashboard => AppStrings.dashboard,
        DefaultScreen.history => AppStrings.history,
        DefaultScreen.settings => AppStrings.settings,
      };

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.signOut),
        content: Text(AppStrings.signOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              AppStrings.signOut,
              style: const TextStyle(color: Color(0xFFFF5F5F)),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authRepositoryProvider).signOut();
      if (context.mounted) context.go(AppRoutes.login);
    }
  }
}

class _SettingsHeader extends StatelessWidget {
  final MeterConnectivity connectivity;

  const _SettingsHeader({required this.connectivity});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor =
        isDark ? AppColors.textPrimary : Theme.of(context).colorScheme.onSurface;
    final boltColor = isDark ? AppColors.textPrimary : AppColors.gold;
    final (statusColor, statusLabel) = switch (connectivity) {
      MeterConnectivity.live => (AppColors.online, AppStrings.statusLive),
      MeterConnectivity.stale => (AppColors.warning, AppStrings.statusNotLive),
      MeterConnectivity.none => (AppColors.offline, AppStrings.statusOffline),
    };

    return Row(
      children: [
        Icon(Icons.bolt_rounded, color: boltColor, size: 28),
        const SizedBox(width: AppDimensions.sm),
        Expanded(
          child: Text(
            AppStrings.appName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: titleColor,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.md,
            vertical: AppDimensions.sm,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardBg : AppColors.cardBgLight,
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            border: Border.all(
              color: isDark ? AppColors.inputBorder : AppColors.dividerLight,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Text(
                statusLabel,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: titleColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
