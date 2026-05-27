import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/meter_wifi_config.dart';
import '../repositories/wifi_config_repository.dart';

final wifiConfigRepositoryProvider = Provider<WifiConfigRepository>((ref) {
  return WifiConfigRepository(Supabase.instance.client);
});

/// Latest Wi‑Fi network saved for the meter (newest row).
final meterWifiProvider = FutureProvider<MeterWifiConfig?>((ref) async {
  return ref.watch(wifiConfigRepositoryProvider).fetchLatest();
});
