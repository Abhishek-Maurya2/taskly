import '../models/task_models.dart';

abstract class TaskRepository {
  Future<void> init();
  Future<List<TaskListModel>> loadLists();
  Future<List<TaskModel>> loadTasks();

  // Deprecated bulk persist, kept for backward compatibility if needed,
  // but implementers should prefer granular updates.
  Future<void> persist({
    required List<TaskListModel> lists,
    required List<TaskModel> tasks,
  });

  // Granular updates
  Future<void> addList(TaskListModel list);
  Future<void> updateList(TaskListModel list);
  Future<void> deleteList(String id);

  Future<void> addTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
}
