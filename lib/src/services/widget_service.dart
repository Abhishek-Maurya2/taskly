import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import '../models/task_models.dart';

class WidgetService {
  static const String appWidgetProvider = 'TaskWidgetProvider';

  static Future<void> updateWidget(
    List<TaskModel> tasks, {
    String? listName,
  }) async {
    // Filter for active tasks (not completed)
    final activeTasks = tasks.where((t) => !t.completed).toList();

    // Sort by due date if available, otherwise creation date
    activeTasks.sort((a, b) {
      if (a.dueAt != null && b.dueAt != null) {
        return a.dueAt!.compareTo(b.dueAt!);
      } else if (a.dueAt != null) {
        return -1; // a comes first
      } else if (b.dueAt != null) {
        return 1; // b comes first
      } else {
        return b.createdAt.compareTo(a.createdAt);
      }
    });

    final taskCount = activeTasks.length;
    final nextTaskTitle = activeTasks.isNotEmpty
        ? activeTasks.first.title
        : 'No active tasks';
    final nextTaskDesc = activeTasks.isNotEmpty
        ? (activeTasks.first.dueAt != null
              ? 'Due: ${_formatDate(activeTasks.first.dueAt!)}'
              : '')
        : '';

    final tasksJson = activeTasks
        .take(20)
        .map((t) => {'id': t.id, 'title': t.title, 'completed': t.completed})
        .toList();

    await HomeWidget.saveWidgetData<String>(
      'list_name',
      listName ?? 'My Tasks',
    );
    await HomeWidget.saveWidgetData<String>('title', 'Taskly');
    await HomeWidget.saveWidgetData<String>(
      'message',
      '$taskCount active tasks\n\nNext: $nextTaskTitle\n$nextTaskDesc',
    );
    await HomeWidget.saveWidgetData<String>(
      'widget_tasks',
      jsonEncode(tasksJson),
    );

    await HomeWidget.updateWidget(
      name: appWidgetProvider,
      iOSName: 'TasklyWidget',
    );
    print("Widget updated with: $taskCount active tasks");
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
