import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task_models.dart';
import 'task_repository.dart';

class LocalTaskRepository implements TaskRepository {
  static const _listsKey = 'taskly_lists';
  static const _tasksKey = 'taskly_tasks';

  SharedPreferences? _prefs;

  @override
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<List<TaskListModel>> loadLists() async {
    final raw = _prefs?.getString(_listsKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => TaskListModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  @override
  Future<List<TaskModel>> loadTasks() async {
    final raw = _prefs?.getString(_tasksKey);
    if (raw == null) return [];
    return TaskModel.decode(raw);
  }

  @override
  Future<void> persist({
    required List<TaskListModel> lists,
    required List<TaskModel> tasks,
  }) async {
    await _saveLists(lists);
    await _saveTasks(tasks);
  }

  Future<void> _saveLists(List<TaskListModel> lists) async {
    await _prefs?.setString(
      _listsKey,
      jsonEncode(lists.map((l) => l.toMap()).toList()),
    );
  }

  Future<void> _saveTasks(List<TaskModel> tasks) async {
    await _prefs?.setString(_tasksKey, TaskModel.encode(tasks));
  }

  // Granular implementations using Read-Modify-Write

  @override
  Future<void> addList(TaskListModel list) async {
    final currentLists = await loadLists();
    currentLists.add(list);
    await _saveLists(currentLists);
  }

  @override
  Future<void> updateList(TaskListModel list) async {
    final currentLists = await loadLists();
    final index = currentLists.indexWhere((l) => l.id == list.id);
    if (index != -1) {
      currentLists[index] = list;
      await _saveLists(currentLists);
    }
  }

  @override
  Future<void> deleteList(String id) async {
    final currentLists = await loadLists();
    currentLists.removeWhere((l) => l.id == id);
    await _saveLists(currentLists);

    // Also delete tasks in this list?
    // TaskStore handles filtering, but Repository should probably enforce referential integrity locally too?
    // For now, mirroring TaskStore logic: TaskStore deletes tasks too.
    // We should probably remove tasks for this list here as well to keep disk clean.
    final currentTasks = await loadTasks();
    currentTasks.removeWhere((t) => t.listId == id);
    await _saveTasks(currentTasks);
  }

  @override
  Future<void> addTask(TaskModel task) async {
    final currentTasks = await loadTasks();
    currentTasks.add(task);
    await _saveTasks(currentTasks);
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    final currentTasks = await loadTasks();
    final index = currentTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      currentTasks[index] = task;
      await _saveTasks(currentTasks);
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    final currentTasks = await loadTasks();
    currentTasks.removeWhere((t) => t.id == id);
    await _saveTasks(currentTasks);
  }
}
