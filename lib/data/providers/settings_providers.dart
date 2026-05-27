import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_strings.dart';

const _deviceIdKey = 'device_id';

/// Provides the current device ID, persisted to SharedPreferences.
final deviceIdProvider =
    NotifierProvider<DeviceIdNotifier, String>(DeviceIdNotifier.new);

class DeviceIdNotifier extends Notifier<String> {
  @override
  String build() {
    _load();
    return AppStrings.defaultDeviceId;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_deviceIdKey);
    if (id != null && id.isNotEmpty) {
      state = id;
    }
  }

  Future<void> setDeviceId(String id) async {
    state = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deviceIdKey, id);
  }
}
