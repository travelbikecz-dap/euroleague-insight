import 'package:flutter/material.dart';

class AppTheme {
  /// Bright accent on dark backgrounds (nav, live badges, etc.).
  static const Color brandOrange = Color(0xFFFF9800);

  /// Light accent — used for nav selection and key highlights only.
  static const Color brandOrangeOnLight = Color(0xFFD35400);

  /// Dark pad behind white-letter logos in light mode (neutral, not navy).
  static const Color logoBackdropLight = Color(0xFF3C3C40);

  /// Light mode: iOS-style neutral (white cards on grouped gray).
  static const Color _lightSurface = Color(0xFFF2F2F7);
  static const Color _lightOnSurface = Color(0xFF1C1C1E);
  static const Color _lightOnSurfaceVariant = Color(0xFF636366);
  static const Color _lightOutline = Color(0xFFD1D1D6);
  static const Color _lightCard = Color(0xFFFFFFFF);
  static const Color _lightElevatedCard = Color(0xFFE5E5EA);

  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData get light => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primary = isDark ? brandOrange : brandOrangeOnLight;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: isDark ? Colors.black : Colors.white,
      secondary: primary,
      onSecondary: isDark ? Colors.black : Colors.white,
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
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? colorScheme.surface : _lightCard,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.45),
        type: BottomNavigationBarType.fixed,
        elevation: isDark ? 0 : 8,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
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

  bool get isLightTheme => Theme.of(this).brightness == Brightness.light;

  Color get cardColor => cs.surfaceContainerHigh;

  Color get elevatedCard => cs.surfaceContainerHighest;

  /// Orange in dark mode; muted gray in light (status lines, meta text).
  Color get statusHighlightColor =>
      isLightTheme ? cs.onSurfaceVariant : cs.primary;

  Color get muted => cs.onSurface.withValues(alpha: 0.7);

  Color get subtle => cs.onSurface.withValues(alpha: 0.54);

  Color get faint => cs.onSurface.withValues(alpha: 0.38);

  static const Color _lightCardBorder = Color(0xFF8E8E93);
  static const Color _lightElevatedBorder = Color(0xFF98989D);

  /// Main content cards — border in light mode only.
  BoxDecoration cardDecoration({double radius = 12}) {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(radius),
      border: isLightTheme
          ? Border.all(color: _lightCardBorder, width: 1)
          : null,
      boxShadow: isLightTheme
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
    );
  }

  /// Nested panels / stat chips inside cards — border in light mode only.
  BoxDecoration elevatedCardDecoration({double radius = 12}) {
    return BoxDecoration(
      color: elevatedCard,
      borderRadius: BorderRadius.circular(radius),
      border: isLightTheme
          ? Border.all(color: _lightElevatedBorder, width: 1)
          : null,
    );
  }
}
