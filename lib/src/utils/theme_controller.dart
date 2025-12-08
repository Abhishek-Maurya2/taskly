import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart' as mcu;
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController({Color fallbackSeed = const Color(0xFF4A6B5F)})
    : _seedColor = fallbackSeed;

  static const _seedKey = 'theme_seed';
  static const _modeKey = 'theme_mode';
  static const _dynamicKey = 'use_dynamic_color';

  Color _seedColor;
  ThemeMode _themeMode = ThemeMode.system;
  bool _useDynamicColor = false;
  bool _supportsDynamicColor = false;
  mcu.CorePalette? _dynamicPalette;

  bool get supportsDynamicColor => _supportsDynamicColor;
  bool get useDynamicColor => _useDynamicColor && _supportsDynamicColor;
  ThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;

  Color get activeSeedColor {
    if (useDynamicColor && _dynamicPalette != null) {
      final isDark = _themeMode == ThemeMode.dark;
      return Color(_dynamicPalette!.primary.get(isDark ? 80 : 40));
    }
    return _seedColor;
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = _stringToMode(prefs.getString(_modeKey)) ?? ThemeMode.system;
    _seedColor = Color(prefs.getInt(_seedKey) ?? _encodeColor(_seedColor));
    _useDynamicColor = prefs.getBool(_dynamicKey) ?? false;

    _dynamicPalette = await DynamicColorPlugin.getCorePalette();
    _supportsDynamicColor = _dynamicPalette != null;

    if (!_supportsDynamicColor) {
      _useDynamicColor = false;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, _modeToString(mode));
    notifyListeners();
  }

  Future<void> setSeedColor(Color color) async {
    _seedColor = color;
    _useDynamicColor = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_seedKey, _encodeColor(color));
    await prefs.setBool(_dynamicKey, _useDynamicColor);
    notifyListeners();
  }

  Future<void> setUseDynamicColor(bool value) async {
    if (!_supportsDynamicColor) {
      _useDynamicColor = false;
    } else {
      _useDynamicColor = value;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dynamicKey, _useDynamicColor);
    notifyListeners();
  }

  String _modeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  ThemeMode? _stringToMode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return null;
    }
  }

  int _encodeColor(Color color) {
    // Using value to persist the ARGB color; ignore deprecation in favor of compact encoding.
    // ignore: deprecated_member_use
    return color.value;
  }
}
