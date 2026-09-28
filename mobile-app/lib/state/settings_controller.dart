import 'package:flutter/widgets.dart';

import '../core/app_config.dart';
import '../data/local/settings_store.dart';

/// Holds the language chosen by the worker and remembers it on the device.
class SettingsController extends ChangeNotifier {
  SettingsController({required SettingsStore store}) : _store = store;

  final SettingsStore _store;

  Locale _locale = AppConfig.fallbackLocale;

  Locale get locale => _locale;

  /// Reads the saved language, called once while the app starts.
  Future<void> load() async {
    final String? languageCode = _store.getString(SettingsKeys.locale);
    if (languageCode == null) return;
    _locale = AppConfig.supportedLocales.firstWhere(
      (Locale locale) => locale.languageCode == languageCode,
      orElse: () => AppConfig.fallbackLocale,
    );
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale.languageCode == locale.languageCode) return;
    _locale = locale;
    await _store.setString(SettingsKeys.locale, locale.languageCode);
    notifyListeners();
  }
}
