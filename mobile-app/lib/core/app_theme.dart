import 'package:flutter/material.dart';

/// Colors and component styling shared by every screen.
class AppTheme {
  const AppTheme._();

  /// A restrained Indian tricolour palette for a public-service app.
  static const Color saffron = Color(0xFFFF9933);
  static const Color navy = Color(0xFF000080);
  static const Color indiaGreen = Color(0xFF138808);
  static const Color cream = Color(0xFFF7F9FF);
  static const Color ink = Color(0xFF172033);
  static const Color warmDark = Color(0xFF28211D);
  static const Color brand = navy;
  static const Color surface = cream;
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
        ColorScheme.fromSeed(
          seedColor: saffron,
          brightness: Brightness.dark,
          surface: warmDark,
        ),
        warmDark,
      );

  static ThemeData _base(ColorScheme scheme, Color? background) {
    final ThemeData theme = ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      useMaterial3: true,
    );
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: ink,
        centerTitle: false,
        elevation: 2,
        shadowColor: navy.withValues(alpha: 0.08),
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        floatingLabelStyle: const TextStyle(
          color: navy,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          gapPadding: 8,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          gapPadding: 8,
          borderSide: BorderSide(color: navy.withValues(alpha: 0.18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          gapPadding: 8,
          borderSide: const BorderSide(color: navy, width: 2),
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
