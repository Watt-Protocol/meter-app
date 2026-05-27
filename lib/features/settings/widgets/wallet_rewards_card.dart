import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../features/dashboard/widgets/total_rewards_card.dart';
import '../../../routing/app_router.dart';
import 'settings_section_header.dart';

class WalletRewardsCard extends StatelessWidget {
  final String? walletAddress;
  final VoidCallback onPayouts;
  final VoidCallback onExplorer;
  final VoidCallback? onEditWallet;

  const WalletRewardsCard({
    super.key,
    this.walletAddress,
    required this.onPayouts,
    required this.onExplorer,
    this.onEditWallet,
  });

  @override
  Widget build(BuildContext context) {
    final wallet = truncateWallet(walletAddress);
    final hasWallet = walletAddress != null && walletAddress!.isNotEmpty;

    return SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.connectedWallet.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                            letterSpacing: 1.2,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      hasWallet ? wallet : AppStrings.noWalletSet,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: hasWallet
                                ? null
                                : AppColors.textMuted,
                          ),
                    ),
                    if (onEditWallet != null) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: onEditWallet,
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: Text(
                          hasWallet ? AppStrings.editWallet : AppStrings.editWallet,
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.gold,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: hasWallet
                    ? () => _copyWallet(context, walletAddress!)
                    : null,
                icon: const Icon(Icons.copy_rounded, size: 20),
                color: hasWallet ? AppColors.gold : AppColors.textMuted,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                tooltip: AppStrings.copy,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.arrow_upward_rounded,
                  label: AppStrings.send,
                  onTap: hasWallet ? () => context.push(AppRoutes.walletSend) : null,
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: _ActionButton(
                  icon: Icons.arrow_downward_rounded,
                  label: AppStrings.receive,
                  onTap: hasWallet ? () => context.push(AppRoutes.walletReceive) : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.history_rounded,
                  label: AppStrings.payouts,
                  onTap: onPayouts,
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: _ActionButton(
                  icon: Icons.explore_outlined,
                  label: AppStrings.explorer,
                  onTap: hasWallet ? onExplorer : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _copyWallet(BuildContext context, String address) {
    Clipboard.setData(ClipboardData(text: address));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.copied),
        backgroundColor: AppColors.gold,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.inputBorder : AppColors.dividerLight;

    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(
        icon,
        size: 18,
        color: enabled ? AppColors.gold : AppColors.textMuted,
      ),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: enabled
            ? Theme.of(context).colorScheme.onSurface
            : AppColors.textMuted,
        side: BorderSide(color: borderColor),
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
      ),
    );
  }
}
