import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/notification_service.dart';
import '../../data/models/sensor_reading.dart';
import '../../data/providers/app_preferences_providers.dart';
import '../../data/providers/sensor_providers.dart';

/// Monitors sensor readings and triggers notifications for
/// abnormal conditions like high voltage, low PF, and offline devices.
class NotificationMonitor {
  final NotificationService _service = NotificationService.instance;

  bool _wasOnline = true;
  bool _highVoltageAlerted = false;
  bool _lowPfAlerted = false;
  bool _milestoneAlerted = false;

  /// Evaluate the latest reading and send notifications as needed.
  void evaluate(
    SensorReading reading, {
    required bool notificationsEnabled,
    required bool highVoltageEnabled,
  }) {
    if (!notificationsEnabled) return;

    final now = DateTime.now();
    final diff = now.difference(reading.createdAt).inSeconds;
    final isOnline = diff < 30;

    if (!isOnline && _wasOnline) {
      _service.notifyDeviceOffline(reading.deviceId);
      _wasOnline = false;
    } else if (isOnline && !_wasOnline) {
      _service.notifyDeviceOnline(reading.deviceId);
      _wasOnline = true;
    }

    if (highVoltageEnabled &&
        reading.voltage > NotificationService.highVoltageThreshold) {
      if (!_highVoltageAlerted) {
        _service.notifyHighVoltage(reading.voltage);
        _highVoltageAlerted = true;
      }
    } else {
      _highVoltageAlerted = false;
    }

    if (reading.powerFactor > 0 &&
        reading.powerFactor < NotificationService.lowPowerFactorThreshold) {
      if (!_lowPfAlerted) {
        _service.notifyLowPowerFactor(reading.powerFactor);
        _lowPfAlerted = true;
      }
    } else {
      _lowPfAlerted = false;
    }

    if (reading.energy >= NotificationService.energyMilestoneKwh) {
      if (!_milestoneAlerted) {
        _service.notifyEnergyMilestone(reading.energy);
        _milestoneAlerted = true;
      }
    }
  }

  void resetAlerts() {
    _highVoltageAlerted = false;
    _lowPfAlerted = false;
    _milestoneAlerted = false;
    _wasOnline = true;
  }
}

final notificationMonitorProvider = Provider<NotificationMonitor>((ref) {
  final monitor = NotificationMonitor();

  ref.listen<AsyncValue<SensorReading?>>(
    latestReadingProvider,
    (previous, next) {
      next.whenData((reading) {
        if (reading == null) return;
        monitor.evaluate(
          reading,
          notificationsEnabled: ref.read(notificationsEnabledProvider),
          highVoltageEnabled: ref.read(highVoltageAlertProvider),
        );
      });
    },
  );

  return monitor;
});
