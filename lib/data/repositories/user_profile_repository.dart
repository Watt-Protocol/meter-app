import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../models/user_profile.dart';

class UserProfileRepository {
  final SupabaseClient _client;

  UserProfileRepository(this._client);

  Future<UserProfile?> fetchProfile(int userId) async {
    final dynamic raw = await _client.rpc(
      SupabaseConfig.profileRpc,
      params: {'p_user_id': userId},
    );

    final Map<String, dynamic> result;
    if (raw is Map<String, dynamic>) {
      result = raw;
    } else if (raw is Map) {
      result = Map<String, dynamic>.from(raw);
    } else {
      return null;
    }

    if (result['success'] != true) return null;
    return UserProfile.fromJson(result);
  }

  Future<bool> updateWallet(int userId, String? walletAddress) async {
    final dynamic raw = await _client.rpc(
      SupabaseConfig.updateWalletRpc,
      params: {
        'p_user_id': userId,
        'p_wallet_address': walletAddress?.trim() ?? '',
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
}
