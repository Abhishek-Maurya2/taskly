import 'dart:io';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'src/app.dart';
import 'src/data/supabase_task_repository.dart';
import 'src/notifiers/unit_settings_notifier.dart';
import 'src/services/notification_service.dart';
import 'src/state/task_store.dart';
import 'src/utils/preferences_helper.dart';
import 'src/utils/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  await NotificationService.instance.initialize();
  await PreferencesHelper.init();

  final repository = SupabaseTaskRepository();
  final taskStore = TaskStore(repository);
  await taskStore.initialize();

  final themeController = ThemeController();
  await themeController.initialize();
  await themeController.checkDynamicColorSupport();

  final unitSettings = UnitSettingsNotifier();

  // Determine initial route based on widget launch
  String initialRoute = AppRoutes.home;

  Uri? widgetUri;
  if (Platform.isAndroid || Platform.isIOS) {
    widgetUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    debugPrint('Widget Launch URI: $widgetUri');

    if (widgetUri != null) {
      debugPrint('Widget URI Host: ${widgetUri.host}');
      if (widgetUri.host == 'opentask') {
        initialRoute = AppRoutes.addTask;
        debugPrint('Setting initial route to: addTask');
      } else if (widgetUri.host == 'openlists') {
        initialRoute = AppRoutes.selectList;
        debugPrint('Setting initial route to: selectList');
      }
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<TaskStore>.value(value: taskStore),
        ChangeNotifierProvider<ThemeController>.value(value: themeController),
        ChangeNotifierProvider<UnitSettingsNotifier>.value(value: unitSettings),
      ],
      child: TasklyApp(initialRoute: initialRoute),
    ),
  );
}
