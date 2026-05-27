import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../data/providers/app_preferences_providers.dart';
import 'widgets/settings_notifications_card.dart';

/// Notification toggles and alert thresholds.
class NotificationsSettingsScreen extends ConsumerWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsOn = ref.watch(notificationsEnabledProvider);
    final highVoltageOn = ref.watch(highVoltageAlertProvider);
    final staleMinutes = ref.watch(staleDataMinutesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.scaffoldBg
          : Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppStrings.notificationsSettingsTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.md,
          0,
          AppDimensions.md,
          AppDimensions.xl,
        ),
        children: [
          SettingsNotificationsCard(
            notificationsEnabled: notificationsOn,
            highVoltageEnabled: highVoltageOn,
            staleMinutes: staleMinutes,
            onNotificationsChanged: (v) => ref
                .read(notificationsEnabledProvider.notifier)
                .setValue(v),
            onHighVoltageChanged: (v) =>
                ref.read(highVoltageAlertProvider.notifier).setValue(v),
            onStaleMinutesChanged: (v) =>
                ref.read(staleDataMinutesProvider.notifier).setValue(v),
          ),
        ],
      ),
    );
  }
}
