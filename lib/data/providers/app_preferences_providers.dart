import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routing/app_router.dart';

const _themeModeKey = 'theme_mode';
const _defaultScreenKey = 'default_screen';
const _notificationsEnabledKey = 'notifications_enabled';
const _staleDataMinutesKey = 'stale_data_minutes';
const _highVoltageAlertKey = 'alert_high_voltage';

/// Landing tab after login / splash.
enum DefaultScreen { dashboard, history, settings }

String defaultRouteFor(DefaultScreen screen) {
  return switch (screen) {
    DefaultScreen.dashboard => AppRoutes.dashboard,
    DefaultScreen.history => AppRoutes.history,
    DefaultScreen.settings => AppRoutes.settings,
  };
}

int defaultTabIndexFor(DefaultScreen screen) {
  return switch (screen) {
    DefaultScreen.dashboard => 0,
    DefaultScreen.history => 1,
    DefaultScreen.settings => 2,
  };
}

DefaultScreen _parseDefaultScreen(String? raw) {
  return switch (raw) {
    'history' => DefaultScreen.history,
    'settings' => DefaultScreen.settings,
    _ => DefaultScreen.dashboard,
  };
}

ThemeMode _parseThemeMode(String? raw) {
  return switch (raw) {
    'light' => ThemeMode.light,
    'system' => ThemeMode.system,
    _ => ThemeMode.dark,
  };
}

String _themeModeToString(ThemeMode mode) {
  return switch (mode) {
    ThemeMode.light => 'light',
    ThemeMode.system => 'system',
    ThemeMode.dark => 'dark',
  };
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _load();
    return ThemeMode.dark;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = _parseThemeMode(prefs.getString(_themeModeKey));
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, _themeModeToString(mode));
  }
}

final defaultScreenProvider =
    NotifierProvider<DefaultScreenNotifier, DefaultScreen>(
  DefaultScreenNotifier.new,
);

class DefaultScreenNotifier extends Notifier<DefaultScreen> {
  @override
  DefaultScreen build() {
    _load();
    return DefaultScreen.dashboard;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = _parseDefaultScreen(prefs.getString(_defaultScreenKey));
  }

  Future<void> setScreen(DefaultScreen screen) async {
    state = screen;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultScreenKey, screen.name);
  }
}

/// Resolved default route (async-safe for splash).
final defaultRouteProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final screen = _parseDefaultScreen(prefs.getString(_defaultScreenKey));
  return defaultRouteFor(screen);
});

final notificationsEnabledProvider =
    NotifierProvider<BoolPrefNotifier, bool>(
  () => BoolPrefNotifier(_notificationsEnabledKey, defaultValue: true),
);

final highVoltageAlertProvider = NotifierProvider<BoolPrefNotifier, bool>(
  () => BoolPrefNotifier(_highVoltageAlertKey, defaultValue: true),
);

class BoolPrefNotifier extends Notifier<bool> {
  BoolPrefNotifier(this.key, {required this.defaultValue});

  final String key;
  final bool defaultValue;

  @override
  bool build() {
    _load();
    return defaultValue;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(key)) {
      state = prefs.getBool(key) ?? defaultValue;
    }
  }

  Future<void> setValue(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
}

final staleDataMinutesProvider =
    NotifierProvider<IntPrefNotifier, int>(
  () => IntPrefNotifier(_staleDataMinutesKey, defaultValue: 15),
);

class IntPrefNotifier extends Notifier<int> {
  IntPrefNotifier(this.key, {required this.defaultValue});

  final String key;
  final int defaultValue;

  @override
  int build() {
    _load();
    return defaultValue;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt(key) ?? defaultValue;
  }

  Future<void> setValue(int value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }
}
