import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/user_profile.dart';
import '../../../routing/app_router.dart';

class GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.divider.withValues(alpha: 0.35)
      ..strokeWidth = 0.5;

    const spacing = 24.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

String truncateWallet(String? address) {
  if (address == null || address.length < 10) return '--';
  return '${address.substring(0, 6)}…${address.substring(address.length - 4)}';
}

class TotalRewardsCard extends StatelessWidget {
  final UserProfile? profile;
  final bool isLoading;
  final bool compact;

  const TotalRewardsCard({
    super.key,
    this.profile,
    this.isLoading = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    /// Confirmed mints only (on-chain user leg); excludes fractional pending kWh.
    final mintedWatt = profile?.creditedWatt ?? 0;
    final wallet = truncateWallet(profile?.walletAddress);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: GridBackgroundPainter()),
          ),
          Padding(
            padding: EdgeInsets.all(
              compact ? AppDimensions.md : AppDimensions.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.totalRewards,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w600,
                            fontSize: compact ? 10 : null,
                          ),
                    ),
                    GestureDetector(
                      onTap: profile?.walletAddress != null
                          ? () {
                              Clipboard.setData(
                                ClipboardData(text: profile!.walletAddress!),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Wallet address copied'),
                                  backgroundColor: AppColors.gold,
                                ),
                              );
                            }
                          : null,
                      child: Text(
                        wallet,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.gold.withValues(alpha: 0.8),
                              fontFamily: 'monospace',
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.md),
                if (isLoading)
                  SizedBox(
                    height: compact ? 32 : 48,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.gold,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                else ...[
                  Text(
                    '${mintedWatt.toStringAsFixed(1)} \$WATT',
                    style: (compact
                            ? Theme.of(context).textTheme.headlineSmall
                            : Theme.of(context).textTheme.displaySmall)
                        ?.copyWith(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
                SizedBox(height: compact ? AppDimensions.sm : AppDimensions.md),
                Row(
                  children: [
                    Expanded(
                      child: _QuickWalletButton(
                        label: AppStrings.send,
                        icon: Icons.arrow_upward_rounded,
                        onTap: () => context.push(AppRoutes.walletSend),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    Expanded(
                      child: _QuickWalletButton(
                        label: AppStrings.receive,
                        icon: Icons.arrow_downward_rounded,
                        onTap: () => context.push(AppRoutes.walletReceive),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickWalletButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickWalletButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: AppColors.gold),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.inputBorder),
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
      ),
    );
  }
}
