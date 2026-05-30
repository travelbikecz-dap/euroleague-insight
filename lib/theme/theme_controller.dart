import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const _prefsKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  /// Loads saved preference. Defaults to [ThemeMode.system] if unset.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_prefsKey);
      final loaded = _themeModeFromStorage(stored) ?? ThemeMode.system;
      if (_themeMode == loaded) return;
      _themeMode = loaded;
      notifyListeners();
    } on MissingPluginException catch (e) {
      debugPrint('ThemeController.load: $e — run full restart after adding plugins');
    } catch (e) {
      debugPrint('ThemeController.load failed: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, mode.name);
    } on MissingPluginException catch (e) {
      debugPrint('ThemeController.save: $e — run full restart after adding plugins');
    } catch (e) {
      debugPrint('ThemeController.save failed: $e');
    }
  }

  static ThemeMode? _themeModeFromStorage(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => null,
    };
  }
}

class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    assert(scope != null, 'ThemeScope not found');
    return scope!.notifier!;
  }
}
