import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart';

class OfflineMeterPanel extends StatelessWidget {
  final DateTime? lastSeen;

  const OfflineMeterPanel({super.key, this.lastSeen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.offline.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Text(
            AppStrings.deviceOffline,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          if (lastSeen != null) ...[
            const SizedBox(height: AppDimensions.xs),
            Text(
              AppDateUtils.lastReadingAgo(lastSeen!),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
