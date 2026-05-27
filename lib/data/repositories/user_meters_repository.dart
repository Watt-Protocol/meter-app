import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../models/user_meter.dart';

class UserMetersRepository {
  final SupabaseClient _client;

  UserMetersRepository(this._client);

  Future<List<UserMeter>> fetchMeters(int userId) async {
    final dynamic raw = await _client.rpc(
      SupabaseConfig.metersListRpc,
      params: {'p_user_id': userId},
    );

    final Map<String, dynamic> result;
    if (raw is Map<String, dynamic>) {
      result = raw;
    } else if (raw is Map) {
      result = Map<String, dynamic>.from(raw);
    } else {
      return _fallbackMeters();
    }

    if (result['success'] != true) return _fallbackMeters();

    final list = result['meters'];
    if (list is! List || list.isEmpty) return _fallbackMeters();

    return list
        .map((e) => UserMeter.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<bool> addMeter({
    required int userId,
    required String label,
    required String deviceId,
    String? location,
  }) async {
    final dynamic raw = await _client.rpc(
      SupabaseConfig.metersAddRpc,
      params: {
        'p_user_id': userId,
        'p_label': label.trim(),
        'p_device_id': deviceId.trim(),
        'p_location': location?.trim(),
      },
    );

    final Map<String, dynamic> result;
    if (raw is Map<String, dynamic>) {
      result = raw;
    } else if (raw is Map) {
      result = Map<String, dynamic>.from(raw);
    } else {
      return false;
    }

    return result['success'] == true;
  }

  List<UserMeter> _fallbackMeters() {
    return [
      UserMeter.local(
        label: 'Home',
        deviceId: 'esp32_001',
        location: 'Kitchen',
      ),
    ];
  }
}
