import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/local_task_repository.dart';
import 'screens/home_shell.dart';
import 'state/task_store.dart';
import 'theme.dart';
import 'utils/theme_controller.dart';

class TasklyApp extends StatefulWidget {
  const TasklyApp({super.key});

  @override
  State<TasklyApp> createState() => _TasklyAppState();
}

class _TasklyAppState extends State<TasklyApp> {
  late final LocalTaskRepository _repository;
  late final TaskStore _store;
  late final ThemeController _themeController;
  late final Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _repository = LocalTaskRepository();
    _store = TaskStore(_repository);
    _themeController = ThemeController();
    _initFuture = _initialize();
  }

  Future<void> _initialize() async {
    await Future.wait([_store.initialize(), _themeController.initialize()]);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TaskStore>.value(value: _store),
        ChangeNotifierProvider<ThemeController>.value(value: _themeController),
      ],
      child: Consumer<ThemeController>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'Taskly',
            debugShowCheckedModeBanner: false,
            theme: buildTasklyTheme(
              seed: theme.activeSeedColor,
              brightness: Brightness.light,
            ),
            darkTheme: buildTasklyTheme(
              seed: theme.activeSeedColor,
              brightness: Brightness.dark,
            ),
            themeMode: theme.themeMode,
            home: FutureBuilder<void>(
              future: _initFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                    body: Center(
                      child: ExpressiveLoadingIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Scaffold(
                    body: Center(
                      child: Text('Failed to load data: ${snapshot.error}'),
                    ),
                  );
                }
                return const HomeShell();
              },
            ),
          );
        },
      ),
    );
  }
}
