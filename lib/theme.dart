import 'package:material_ui/material_ui.dart';

/// Brand colours of the app.
class Brand {
  static const orange = Color(0xFFDE632C);
  static const navy = Color(0xFF1C2240);
  static const background = Color(0xFF0B0E14);
  static const card = Color(0xFF161A21);
  static const green = Color(0xFF3FB950);
  static const amber = Color(0xFFE3B341);
  static const red = Color(0xFFF85149);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: Brand.orange,
    brightness: Brightness.dark,
    surface: Brand.card,
  );
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: Brand.background,
    appBarTheme: const AppBarTheme(backgroundColor: Brand.background, centerTitle: false),
    cardTheme: CardThemeData(
      color: Brand.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF252B36)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Brand.orange,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
      ),
    ),
  );
}
