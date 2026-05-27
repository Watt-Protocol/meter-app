import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized backend configuration for Supabase and Firebase.
///
/// Replace the placeholder values below with your actual credentials
/// from your Supabase and Firebase dashboards.
class SupabaseConfig {
  SupabaseConfig._();

  // ── Supabase ────────────────────────────────────────────────
  /// Your Supabase project URL (e.g. https://xxxx.supabase.co)
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  /// Your Supabase anon/public key
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Table name for sensor readings
  static const String sensorReadingsTable = 'sensor_readings';

  /// Waitlist table (mobile login via RPC)
  static const String waitlistUsersTable = 'waitlist_users';

  /// RPC: email + password → waitlist session fields
  static const String loginRpc = 'login_waitlist_user';

  /// RPC: user id → wallet + WATT balances
  static const String profileRpc = 'get_user_profile';

  static const String metersListRpc = 'get_user_meters';
  static const String metersAddRpc = 'add_user_meter';

  static const String miningEventsRpc = 'get_user_mining_events';
  static const String miningSummaryRpc = 'get_user_mining_summary';

  static const String userMetersTable = 'user_meters';

  /// Wi‑Fi credentials for the physical meter (latest row wins).
  static const String wifiConfigTable = 'wifi_config';

  static String get explorerBaseUrl =>
      dotenv.env['EXPLORER_BASE_URL'] ??
      'https://sepolia.basescan.org/address/';

  static String get wattContractAddress =>
      dotenv.env['WATT_CONTRACT_ADDRESS'] ??
      '0xf07ce10cE718fEe22dFEe06B4048B734bC95b954';

  /// Base Sepolia = 84532
  static int get chainId =>
      int.tryParse(dotenv.env['CHAIN_ID'] ?? '84532') ?? 84532;

  static const String updateWalletRpc = 'update_user_wallet';

  static double get wattUsdPrice =>
      double.tryParse(dotenv.env['WATT_USD_PRICE'] ?? '0.10') ?? 0.10;

  /// Default product user id (matches firmware SUPABASE_USER_ID)
  static int get defaultUserId =>
      int.tryParse(dotenv.env['APP_USER_ID'] ?? '2') ?? 2;

  // ── Firebase ────────────────────────────────────────────────
  /// Firebase Realtime Database URL
  static String get firebaseDatabaseUrl =>
      dotenv.env['FIREBASE_DATABASE_URL'] ?? dotenv.env['FIREBASE_URL'] ?? '';

  /// Firebase path template for latest reading
  /// Usage: '$firebaseLatestPath/$deviceId/latest'
  static const String firebaseDevicesPath = 'devices';
}
