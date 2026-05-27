import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../data/providers/app_preferences_providers.dart';
import 'widgets/settings_section_header.dart';

/// Display preferences: theme and default landing tab.
class DisplaySettingsScreen extends ConsumerWidget {
  const DisplaySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final defaultScreen = ref.watch(defaultScreenProvider);
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
          AppStrings.displaySettings,
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
          const SettingsSectionHeader(title: AppStrings.appearance),
          SettingsCard(
            child: Column(
              children: [
                _ThemeOption(
                  label: AppStrings.themeDark,
                  selected: themeMode == ThemeMode.dark,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setMode(ThemeMode.dark),
                ),
                const SettingsRowDivider(),
                _ThemeOption(
                  label: AppStrings.themeLight,
                  selected: themeMode == ThemeMode.light,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setMode(ThemeMode.light),
                ),
                const SettingsRowDivider(),
                _ThemeOption(
                  label: AppStrings.themeSystem,
                  selected: themeMode == ThemeMode.system,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setMode(ThemeMode.system),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          const SettingsSectionHeader(title: AppStrings.defaultScreenLabel),
          Padding(
            padding: const EdgeInsets.only(
              left: AppDimensions.xs,
              bottom: AppDimensions.sm,
            ),
            child: Text(
              AppStrings.defaultScreenHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ),
          SettingsCard(
            child: Column(
              children: DefaultScreen.values.map((screen) {
                final isLast = screen == DefaultScreen.values.last;
                return Column(
                  children: [
                    _DefaultScreenOption(
                      label: _screenLabel(screen),
                      selected: defaultScreen == screen,
                      onTap: () => ref
                          .read(defaultScreenProvider.notifier)
                          .setScreen(screen),
                    ),
                    if (!isLast) const SettingsRowDivider(),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _screenLabel(DefaultScreen screen) => switch (screen) {
        DefaultScreen.dashboard => AppStrings.dashboard,
        DefaultScreen.history => AppStrings.history,
        DefaultScreen.settings => AppStrings.settings,
      };
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.gold, size: 22)
              else
                Icon(Icons.circle_outlined,
                    color: AppColors.textMuted, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _DefaultScreenOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DefaultScreenOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.gold, size: 22)
              else
                Icon(Icons.circle_outlined,
                    color: AppColors.textMuted, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
