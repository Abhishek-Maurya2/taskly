import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'notifiers/unit_settings_notifier.dart';
import 'screens/home_shell.dart';
import 'screens/task_editor_screen.dart';
import 'utils/theme_controller.dart';

import 'package:home_widget/home_widget.dart';
import 'screens/widget_action_handler.dart';

class AppRoutes {
  static const String home = '/';
  static const String addTask = '/add-task';
  static const String selectList = '/select-list';
}

class TasklyApp extends StatefulWidget {
  final String initialRoute;

  const TasklyApp({super.key, this.initialRoute = AppRoutes.home});

  @override
  State<TasklyApp> createState() => _TasklyAppState();
}

class _TasklyAppState extends State<TasklyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Handle widget clicks when app is already running
    HomeWidget.widgetClicked.listen(_handleWidgetClick);
  }

  void _handleWidgetClick(Uri? uri) {
    if (uri == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = _navigatorKey.currentState;
      if (navigator == null) return;

      if (uri.host == 'opentask') {
        navigator.pushNamed(AppRoutes.addTask);
      } else if (uri.host == 'openlists') {
        navigator.push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (_, __, ___) =>
                const WidgetActionHandler(action: 'openlists'),
          ),
        );
      }
    });
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeShell(),
          settings: settings,
        );
      case AppRoutes.addTask:
        return MaterialPageRoute(
          builder: (_) => const TaskEditorScreen(),
          settings: settings,
        );
      case AppRoutes.selectList:
        return PageRouteBuilder(
          opaque: false,
          settings: settings,
          pageBuilder: (_, __, ___) =>
              const WidgetActionHandler(action: 'openlists'),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const HomeShell(),
          settings: settings,
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
      initialRoute: widget.initialRoute,
      onGenerateRoute: _onGenerateRoute,
    );
  }
}
