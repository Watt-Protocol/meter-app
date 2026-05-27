import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

enum SettingsNavIconStyle { circle, squareGold }

class SettingsNavRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final SettingsNavIconStyle iconStyle;
  final VoidCallback onTap;

  const SettingsNavRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconStyle = SettingsNavIconStyle.circle,
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
              _IconBadge(icon: icon, style: iconStyle),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final SettingsNavIconStyle style;

  const _IconBadge({required this.icon, required this.style});

  @override
  Widget build(BuildContext context) {
    if (style == SettingsNavIconStyle.squareGold) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        child: Icon(icon, color: Colors.black, size: 24),
      );
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.25),
        ),
      ),
      child: Icon(icon, color: AppColors.gold, size: 22),
    );
  }
}
