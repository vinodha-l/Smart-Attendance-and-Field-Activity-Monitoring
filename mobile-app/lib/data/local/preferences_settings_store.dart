import 'package:shared_preferences/shared_preferences.dart';

import 'settings_store.dart';

/// [SettingsStore] backed by the `shared_preferences` plugin.
///
/// The values are read once when the app starts, which keeps the getters
/// synchronous for the widgets that only need to read a cached value.
class PreferencesSettingsStore implements SettingsStore {
  SharedPreferences? _preferences;
  final Map<String, String> _cache = <String, String>{};

  @override
  Future<void> open() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    _preferences = preferences;
    _cache.clear();
    for (final String key in preferences.getKeys()) {
      final Object? value = preferences.get(key);
      if (value is String) _cache[key] = value;
    }
  }

  @override
  String? getString(String key) => _cache[key];

  @override
  Future<void> setString(String key, String value) async {
    _cache[key] = value;
    await _preferences?.setString(key, value);
  }

  @override
  Future<void> remove(String key) async {
    _cache.remove(key);
    await _preferences?.remove(key);
  }
}

/// [SettingsStore] that keeps everything in memory, used by the tests.
class MemorySettingsStore implements SettingsStore {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<void> open() async {}

  @override
  String? getString(String key) => _values[key];

  @override
  Future<void> setString(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _values.remove(key);
  }
}
