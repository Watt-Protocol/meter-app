import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';

/// Displays the last updated timestamp with a clock icon.
class LastUpdatedText extends StatelessWidget {
  final DateTime? lastUpdated;

  const LastUpdatedText({super.key, this.lastUpdated});

  @override
  Widget build(BuildContext context) {
    final text = lastUpdated != null
        ? 'Last updated: ${AppDateUtils.timeAgo(lastUpdated!)}'
        : 'Waiting for data...';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.access_time_rounded,
          size: 14,
          color: AppColors.textMuted,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
        ),
      ],
    );
  }
}
