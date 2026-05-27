import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// Muted gold section label (e.g. "METERS & DEVICES").
class SettingsSectionHeader extends StatelessWidget {
  final String title;

  const SettingsSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.xs,
        bottom: AppDimensions.sm,
      ),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: const Color(0xFFA89060),
              letterSpacing: 1.8,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
      ),
    );
  }
}

/// Rounded settings group container.
class SettingsCard extends StatelessWidget {
  final Widget child;
  final bool goldAccentBorder;
  final bool goldTopBar;

  const SettingsCard({
    super.key,
    required this.child,
    this.goldAccentBorder = false,
    this.goldTopBar = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? AppColors.cardBgElevated : AppColors.cardBgLight;
    final borderColor = goldAccentBorder
        ? AppColors.gold.withValues(alpha: 0.35)
        : (isDark ? AppColors.inputBorder : AppColors.dividerLight);

    if (goldTopBar) {
      return Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(height: 3, color: AppColors.gold),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: child,
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}

/// Thin divider between rows inside a settings card.
class SettingsRowDivider extends StatelessWidget {
  const SettingsRowDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.divider
          : AppColors.dividerLight,
    );
  }
}
