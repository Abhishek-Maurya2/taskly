import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:provider/provider.dart';

import 'notifiers/unit_settings_notifier.dart';
import 'screens/home_shell.dart';
import 'utils/theme_controller.dart';

class TasklyApp extends StatelessWidget {
  const TasklyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final useExpressive = context
        .watch<UnitSettingsNotifier>()
        .useExpressiveVariant;

    ColorScheme _buildScheme(Brightness brightness) {
      return ColorScheme.fromSeed(
        seedColor: themeController.seedColor,
        brightness: brightness,
        dynamicSchemeVariant: useExpressive
            ? DynamicSchemeVariant.expressive
            : DynamicSchemeVariant.tonalSpot,
      );
    }

    ThemeData _withFonts(ColorScheme scheme) {
      final base = ThemeData.from(colorScheme: scheme, useMaterial3: true);
      return base.copyWith(
        textTheme: base.textTheme.apply(fontFamily: 'FlexFontEn'),
      );
    }

    final lightTheme = _withFonts(_buildScheme(Brightness.light));
    final darkTheme = _withFonts(_buildScheme(Brightness.dark));

    return MaterialApp(
      title: 'Taskly',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeController.themeMode,
      home: const HomeShell(),
    );
  }
}
