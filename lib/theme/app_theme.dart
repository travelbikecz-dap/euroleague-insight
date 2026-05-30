import 'package:flutter/material.dart';

class AppTheme {
  /// Bright accent on dark backgrounds (nav, live badges, etc.).
  static const Color brandOrange = Color(0xFFFF9800);

  /// Light accent — burnt orange on slate surfaces (readable, on-brand).
  static const Color brandOrangeOnLight = Color(0xFFB45309);

  /// Light mode: cool slate gray base (EuroLeague-style, low glare).
  static const Color _lightSurface = Color(0xFF94A0AD);
  static const Color _lightOnSurface = Color(0xFF25272A);
  static const Color _lightOnSurfaceVariant = Color(0xFF484C52);
  static const Color _lightOutline = Color(0xFF7E838A);
  static const Color _lightCard = Color(0xFFA8B2BC);
  static const Color _lightElevatedCard = Color(0xFF707986);

  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData get light => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primary = isDark ? brandOrange : brandOrangeOnLight;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: isDark ? Colors.black : _lightOnSurface,
      secondary: primary,
      onSecondary: isDark ? Colors.black : _lightOnSurface,
      error: Colors.redAccent,
      onError: Colors.white,
      surface: isDark ? Colors.black : _lightSurface,
      onSurface: isDark ? Colors.white : _lightOnSurface,
      onSurfaceVariant: isDark ? Colors.white70 : _lightOnSurfaceVariant,
      outline: isDark ? const Color(0xFF48484A) : _lightOutline,
      surfaceContainerHigh:
          isDark ? const Color(0xFF1C1C1E) : _lightCard,
      surfaceContainerHighest:
          isDark ? const Color(0xFF2C2C2E) : _lightElevatedCard,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.45),
        type: BottomNavigationBarType.fixed,
      ),
      dividerColor: colorScheme.onSurface.withValues(alpha: 0.12),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
      ),
    );
  }
}

extension AppThemeContext on BuildContext {
  ColorScheme get cs => Theme.of(this).colorScheme;

  Color get cardColor => cs.surfaceContainerHigh;

  Color get elevatedCard => cs.surfaceContainerHighest;

  Color get muted => cs.onSurface.withValues(alpha: 0.7);

  Color get subtle => cs.onSurface.withValues(alpha: 0.54);

  Color get faint => cs.onSurface.withValues(alpha: 0.38);
}
