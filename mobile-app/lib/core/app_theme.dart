import 'package:flutter/material.dart';

/// Colors and component styling shared by every screen.
class AppTheme {
  const AppTheme._();

  /// A restrained Indian tricolour palette for a public-service app.
  static const Color saffron = Color(0xFFFF9933);
  static const Color navy = Color(0xFF000080);
  static const Color indiaGreen = Color(0xFF138808);
  static const Color brand = navy;
  static const Color surface = Color(0xFFFFFBF6);
  static const Color positive = indiaGreen;
  static const Color warning = saffron;

  static ThemeData light() => _base(
        ColorScheme.fromSeed(
          seedColor: navy,
          primary: navy,
          secondary: indiaGreen,
          surface: surface,
        ),
        surface,
      );

  static ThemeData dark() => _base(
      ColorScheme.fromSeed(seedColor: saffron, brightness: Brightness.dark),
      null);

  static ThemeData _base(ColorScheme scheme, Color? background) {
    final ThemeData theme = ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      useMaterial3: true,
    );
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: saffron.withValues(alpha: 0.28)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: navy,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: navy,
          minimumSize: const Size.fromHeight(52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: navy.withValues(alpha: 0.28)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
