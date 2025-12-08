import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/app.dart';
import 'src/data/local_task_repository.dart';
import 'src/notifiers/unit_settings_notifier.dart';
import 'src/services/notification_service.dart';
import 'src/state/task_store.dart';
import 'src/utils/preferences_helper.dart';
import 'src/utils/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();
  await PreferencesHelper.init();

  final repository = LocalTaskRepository();
  final taskStore = TaskStore(repository);
  await taskStore.initialize();

  final themeController = ThemeController();
  await themeController.initialize();
  await themeController.checkDynamicColorSupport();

  final unitSettings = UnitSettingsNotifier();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<TaskStore>.value(value: taskStore),
        ChangeNotifierProvider<ThemeController>.value(value: themeController),
        ChangeNotifierProvider<UnitSettingsNotifier>.value(value: unitSettings),
      ],
      child: const TasklyApp(),
    ),
  );
}
