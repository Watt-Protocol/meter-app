import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../models/mining_event.dart';

class MiningEventsRepository {
  final SupabaseClient _client;

  MiningEventsRepository(this._client);

  Future<List<MiningEvent>> fetchEvents({
    required int userId,
    required DateTime from,
    required DateTime to,
  }) async {
    final dynamic raw = await _client.rpc(
      SupabaseConfig.miningEventsRpc,
      params: {
        'p_user_id': userId,
        'p_from': from.toUtc().toIso8601String(),
        'p_to': to.toUtc().toIso8601String(),
      },
    );

    final result = _asMap(raw);
    if (result == null || result['success'] != true) {
      return [];
    }

    final events = result['events'];
    if (events is! List) return [];

    return events
        .map((e) => MiningEvent.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<MiningSummary> fetchSummary({
    required int userId,
    required DateTime from,
    required DateTime to,
  }) async {
    final dynamic raw = await _client.rpc(
      SupabaseConfig.miningSummaryRpc,
      params: {
        'p_user_id': userId,
        'p_from': from.toUtc().toIso8601String(),
        'p_to': to.toUtc().toIso8601String(),
      },
    );

    final result = _asMap(raw);
    if (result == null || result['success'] != true) {
      return MiningSummary.empty();
    }
    return MiningSummary.fromJson(result);
  }

  Map<String, dynamic>? _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return null;
  }
}
