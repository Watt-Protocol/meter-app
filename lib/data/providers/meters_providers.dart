import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_meter.dart';
import '../repositories/user_meters_repository.dart';
import 'auth_providers.dart';
import 'sensor_providers.dart';
import 'settings_providers.dart';

/// Meters for the logged-in user from Supabase `user_meters` + reading status.
final userMetersRepositoryProvider = Provider<UserMetersRepository>((ref) {
  return UserMetersRepository(Supabase.instance.client);
});

final userMetersProvider = FutureProvider<List<UserMeter>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  return ref.watch(userMetersRepositoryProvider).fetchMeters(userId);
});

/// Currently selected meter device id (synced with sensor streams).
final selectedMeterDeviceIdProvider =
    NotifierProvider<SelectedMeterNotifier, String>(
  SelectedMeterNotifier.new,
);

class SelectedMeterNotifier extends Notifier<String> {
  @override
  String build() {
    _load();
    return ref.read(deviceIdProvider);
  }

  Future<void> _load() async {
    final meters = await ref.read(userMetersProvider.future);
    if (meters.isEmpty) return;
    final current = ref.read(deviceIdProvider);
    final exists = meters.any((m) => m.deviceId == current);
    if (!exists) {
      await select(meters.first.deviceId);
    }
  }

  Future<void> select(String deviceId) async {
    state = deviceId;
    ref.read(sensorRepositoryProvider).clearDayCache();
    ref.invalidate(todayUsageProvider);
    await ref.read(deviceIdProvider.notifier).setDeviceId(deviceId);
  }
}

Future<void> refreshUserMeters(WidgetRef ref) {
  ref.invalidate(userMetersProvider);
  return ref.read(userMetersProvider.future);
}

Future<bool> addUserMeter(
  WidgetRef ref, {
  required String label,
  required String deviceId,
  String? location,
}) async {
  final userId = ref.read(currentUserIdProvider);
  if (userId == null) return false;

  final ok = await ref.read(userMetersRepositoryProvider).addMeter(
        userId: userId,
        label: label,
        deviceId: deviceId,
        location: location,
      );
  if (ok) {
    ref.invalidate(userMetersProvider);
    await ref.read(selectedMeterDeviceIdProvider.notifier).select(deviceId);
  }
  return ok;
}
