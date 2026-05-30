import 'package:flutter/material.dart';

class AppTheme {
  static const Color brandOrange = Color(0xFFFF9800);

  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData get light => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: brandOrange,
      onPrimary: Colors.black,
      secondary: brandOrange,
      onSecondary: Colors.black,
      error: Colors.redAccent,
      onError: Colors.white,
      surface: isDark ? Colors.black : const Color(0xFFF2F2F7),
      onSurface: isDark ? Colors.white : const Color(0xFF1C1C1E),
      onSurfaceVariant: isDark ? Colors.white70 : const Color(0xFF5C5C60),
      outline: isDark ? const Color(0xFF48484A) : const Color(0xFFC7C7CC),
      surfaceContainerHigh:
          isDark ? const Color(0xFF1C1C1E) : Colors.white,
      surfaceContainerHighest:
          isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE8E8ED),
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
