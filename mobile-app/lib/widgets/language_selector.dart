import 'package:flutter/material.dart';

import '../app_scope.dart';
import '../l10n/app_localizations.dart';

/// Lets the worker switch between English and Tamil.
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final deps = AppScope.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    return SegmentedButton<String>(
      showSelectedIcon: false,
      segments: <ButtonSegment<String>>[
        ButtonSegment<String>(
          value: 'en',
          label: Text(l10n.languageEnglish),
        ),
        ButtonSegment<String>(value: 'ta', label: Text(l10n.languageTamil)),
      ],
      selected: <String>{deps.settingsController.locale.languageCode},
      onSelectionChanged: (Set<String> selection) =>
          deps.settingsController.setLocale(Locale(selection.first)),
    );
  }
}
