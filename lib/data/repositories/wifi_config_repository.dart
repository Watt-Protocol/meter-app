import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../models/meter_wifi_config.dart';

/// Loads and updates the Wi‑Fi network the physical meter should join.
class WifiConfigRepository {
  final SupabaseClient _client;

  WifiConfigRepository(this._client);

  Future<MeterWifiConfig?> fetchLatest() async {
    final row = await _client
        .from(SupabaseConfig.wifiConfigTable)
        .select('id, ssid, password, created_at')
        .order('id', ascending: false)
        .limit(1)
        .maybeSingle();

    if (row == null) return null;
    return MeterWifiConfig.fromJson(row);
  }

  Future<void> saveNetwork({
    required String ssid,
    required String password,
  }) async {
    final trimmedSsid = ssid.trim();
    if (trimmedSsid.isEmpty) {
      throw ArgumentError('Network name is required');
    }
    await _client.from(SupabaseConfig.wifiConfigTable).insert({
      'ssid': trimmedSsid,
      'password': password,
    });
  }
}
