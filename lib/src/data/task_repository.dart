import '../models/task_models.dart';

abstract class TaskRepository {
  Future<void> init();
  Future<List<TaskListModel>> loadLists();
  Future<List<TaskModel>> loadTasks();
  Future<void> persist({
    required List<TaskListModel> lists,
    required List<TaskModel> tasks,
  });
}
