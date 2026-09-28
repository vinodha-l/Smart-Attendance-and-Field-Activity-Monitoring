/// Persistent key/value store used for the cached session and user settings.
abstract class SettingsStore {
  Future<void> open();

  String? getString(String key);

  Future<void> setString(String key, String value);

  Future<void> remove(String key);
}

/// Keys used by [SettingsStore].
class SettingsKeys {
  const SettingsKeys._();

  static const String session = 'session';
  static const String locale = 'settings.locale';
}
