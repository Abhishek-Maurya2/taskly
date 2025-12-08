import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/local_task_repository.dart';
import 'state/task_store.dart';
import 'theme.dart';
import 'screens/home_shell.dart';

class TasklyApp extends StatelessWidget {
  const TasklyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = LocalTaskRepository();
    final store = TaskStore(repository);

    return MultiProvider(
      providers: [ChangeNotifierProvider<TaskStore>.value(value: store)],
      child: MaterialApp(
        title: 'Taskly',
        debugShowCheckedModeBanner: false,
        theme: buildTasklyTheme(),
        home: FutureBuilder<void>(
          future: store.initialize(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
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
      ),
    );
  }
}
