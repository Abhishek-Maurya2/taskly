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
    await _prefs?.setString(
      _listsKey,
      jsonEncode(lists.map((l) => l.toMap()).toList()),
    );
    await _prefs?.setString(_tasksKey, TaskModel.encode(tasks));
  }
}
