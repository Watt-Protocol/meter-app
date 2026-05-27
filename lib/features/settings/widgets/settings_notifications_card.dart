import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import 'settings_section_header.dart';

class SettingsNotificationsCard extends StatelessWidget {
  final bool notificationsEnabled;
  final bool highVoltageEnabled;
  final int staleMinutes;
  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<bool> onHighVoltageChanged;
  final ValueChanged<int> onStaleMinutesChanged;

  const SettingsNotificationsCard({
    super.key,
    required this.notificationsEnabled,
    required this.highVoltageEnabled,
    required this.staleMinutes,
    required this.onNotificationsChanged,
    required this.onHighVoltageChanged,
    required this.onStaleMinutesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      child: Column(
        children: [
          _MasterToggleRow(
            enabled: notificationsEnabled,
            onChanged: onNotificationsChanged,
          ),
          const SettingsRowDivider(),
          _StaleDataRow(
            minutes: staleMinutes,
            enabled: notificationsEnabled,
            onChanged: onStaleMinutesChanged,
          ),
          const SettingsRowDivider(),
          _HighVoltageRow(
            enabled: highVoltageEnabled,
            masterEnabled: notificationsEnabled,
            onTap: () => onHighVoltageChanged(!highVoltageEnabled),
          ),
        ],
      ),
    );
  }
}

class _MasterToggleRow extends StatelessWidget {
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _MasterToggleRow({
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
      child: Row(
        children: [
          const Icon(Icons.notifications_outlined,
              size: 22, color: AppColors.textMuted),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Text(
              AppStrings.notificationsMaster,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Switch.adaptive(
            value: enabled,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _StaleDataRow extends StatelessWidget {
  final int minutes;
  final bool enabled;
  final ValueChanged<int> onChanged;

  const _StaleDataRow({
    required this.minutes,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.timer_outlined,
                  size: 22, color: AppColors.textMuted),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Text(
                  AppStrings.staleDataThreshold,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              Text(
                '$minutes min',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.xs),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: minutes.toDouble(),
              min: 5,
              max: 60,
              divisions: 11,
              onChanged: enabled ? (v) => onChanged(v.round()) : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _HighVoltageRow extends StatelessWidget {
  final bool enabled;
  final bool masterEnabled;
  final VoidCallback onTap;

  const _HighVoltageRow({
    required this.enabled,
    required this.masterEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: masterEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
          child: Row(
            children: [
              const Icon(Icons.bolt_rounded,
                  size: 22, color: AppColors.textMuted),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: Text(
                  AppStrings.highVoltageAlert,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              _StatusPill(on: enabled && masterEnabled),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool on;

  const _StatusPill({required this.on});

  @override
  Widget build(BuildContext context) {
    if (!on) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.textMuted.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        child: Text(
          'OFF',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.online.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: AppColors.online.withValues(alpha: 0.4)),
      ),
      child: Text(
        'ON',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.online,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}
