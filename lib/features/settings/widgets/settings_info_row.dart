import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';

/// Account info row: icon + stacked uppercase label + value.
class SettingsAccountRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const SettingsAccountRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 20, color: AppColors.textMuted),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textMuted,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
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

/// Referral link row with copy action (no inline URL).
class SettingsReferralRow extends StatelessWidget {
  final String? referralLink;

  const SettingsReferralRow({super.key, this.referralLink});

  @override
  Widget build(BuildContext context) {
    final hasLink = referralLink != null && referralLink!.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasLink ? () => _copy(context, referralLink!) : null,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
          child: Row(
            children: [
              const Icon(Icons.share_outlined, size: 20, color: AppColors.textMuted),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Text(
                  AppStrings.referralLink,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
              IconButton(
                onPressed: hasLink ? () => _copy(context, referralLink!) : null,
                icon: Icon(
                  Icons.copy_rounded,
                  size: 20,
                  color: hasLink ? AppColors.gold : AppColors.textMuted,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                tooltip: AppStrings.copy,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _copy(BuildContext context, String link) {
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.copied),
        backgroundColor: AppColors.gold,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
