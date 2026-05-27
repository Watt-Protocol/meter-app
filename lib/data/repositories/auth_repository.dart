import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';
import '../models/app_session.dart';

/// Authenticates against `waitlist_users` via Supabase RPC [login_waitlist_user].
class AuthRepository extends ChangeNotifier {
  static const _sessionKey = 'watt_app_session';

  final SupabaseClient _client;
  AppSession? _session;

  AuthRepository(this._client);

  AppSession? get session => _session;
  int? get currentUserId => _session?.userId;
  String? get currentUserEmail => _session?.email;
  bool get isAuthenticated => _session != null;

  /// Restore session from device storage (call once at startup).
  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _session = AppSession.fromJson(map);
      notifyListeners();
    } catch (e) {
      debugPrint('[AuthRepository] Invalid stored session: $e');
      await prefs.remove(_sessionKey);
    }
  }

  /// Sign in with email and password (waitlist id=2; dev password 123456 in RPC).
  Future<AppSession> signIn({
    required String email,
    required String password,
  }) async {
    final dynamic raw = await _client.rpc(
      SupabaseConfig.loginRpc,
      params: {
        'p_email': email.trim(),
        'p_password': password,
      },
    );

    final Map<String, dynamic> result;
    if (raw is Map<String, dynamic>) {
      result = raw;
    } else if (raw is Map) {
      result = Map<String, dynamic>.from(raw);
    } else {
      throw AuthException('Unexpected login response');
    }

    if (result['success'] != true) {
      throw AuthException(
        result['error']?.toString() ?? 'invalid_credentials',
      );
    }

    final session = AppSession(
      userId: result['id'] as int,
      email: result['email'] as String,
    );

    _session = session;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
    notifyListeners();
    return session;
  }

  Future<void> signOut() async {
    _session = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    notifyListeners();
  }
}

/// Thrown when [login_waitlist_user] returns failure.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
