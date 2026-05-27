import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';

/// Label + value row with optional full-width copy for hashes and addresses.
class CopyableDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool monospace;
  final bool canCopy;

  const CopyableDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.monospace = false,
    this.canCopy = true,
  });

  @override
  Widget build(BuildContext context) {
    final displayEmpty = value.isEmpty || value == '--';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppDimensions.md),
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.cardBgElevated,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textMuted,
                      letterSpacing: 0.6,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (canCopy && !displayEmpty)
                TextButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(AppStrings.copied),
                        backgroundColor: AppColors.gold,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.gold,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    AppStrings.copy,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDimensions.xs),
          SelectableText(
            displayEmpty ? '--' : value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontFamily: monospace ? 'monospace' : null,
                  fontSize: monospace ? 13 : null,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}
