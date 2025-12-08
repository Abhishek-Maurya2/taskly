import 'package:flutter/material.dart';

import '../utils/preferences_helper.dart';

class UnitSettingsNotifier extends ChangeNotifier {
  bool _useExpressiveVariant =
      PreferencesHelper.getBool('useExpressiveVariant') ?? false;
  bool _useDarkerCardBackground =
      PreferencesHelper.getBool('useDarkerCardBackground') ?? false;

  bool get useExpressiveVariant => _useExpressiveVariant;
  bool get useDarkerCardBackground => _useDarkerCardBackground;

  Future<void> updateColorVariant(bool value) async {
    _useExpressiveVariant = value;
    await PreferencesHelper.setBool('useExpressiveVariant', value);
    notifyListeners();
  }

  Future<void> updateUseDarkerBackground(bool value) async {
    _useDarkerCardBackground = value;
    await PreferencesHelper.setBool('useDarkerCardBackground', value);
    notifyListeners();
  }
}
