import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'notifiers/unit_settings_notifier.dart';
import 'screens/home_shell.dart';
import 'screens/task_editor_screen.dart';
import 'utils/theme_controller.dart';

import 'package:home_widget/home_widget.dart';
import 'screens/widget_action_handler.dart';

class TasklyApp extends StatefulWidget {
  const TasklyApp({super.key});

  @override
  State<TasklyApp> createState() => _TasklyAppState();
}

class _TasklyAppState extends State<TasklyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _checkForWidgetLaunch();
    HomeWidget.widgetClicked.listen(_launchedFromWidget);
  }

  void _checkForWidgetLaunch() {
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_launchedFromWidget);
  }

  void _launchedFromWidget(Uri? uri) {
    if (uri?.host == 'openlists') {
      _navigatorKey.currentState?.push(
        PageRouteBuilder(
          opaque: false, // Transparent background
          pageBuilder: (_, __, ___) =>
              const WidgetActionHandler(action: 'openlists'),
        ),
      );
    } else if (uri?.host == 'opentask') {
      _navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const TaskEditorScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final useExpressive = context
        .watch<UnitSettingsNotifier>()
        .useExpressiveVariant;

    ColorScheme buildScheme(Brightness brightness) {
      return ColorScheme.fromSeed(
        seedColor: themeController.seedColor,
        brightness: brightness,
        dynamicSchemeVariant: useExpressive
            ? DynamicSchemeVariant.expressive
            : DynamicSchemeVariant.tonalSpot,
      );
    }

    ThemeData withFonts(ColorScheme scheme) {
      final base = ThemeData.from(colorScheme: scheme, useMaterial3: true);
      return base.copyWith(
        textTheme: base.textTheme.apply(fontFamily: 'FlexFontEn'),
      );
    }

    final lightTheme = withFonts(buildScheme(Brightness.light));
    final darkTheme = withFonts(buildScheme(Brightness.dark));

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Taskly',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeController.themeMode,
      home: const HomeShell(),
    );
  }
}
