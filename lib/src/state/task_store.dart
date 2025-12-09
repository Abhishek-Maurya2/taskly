import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/task_repository.dart';
import '../models/task_models.dart';
import '../services/notification_service.dart';
import '../services/widget_service.dart';

class TaskStore extends ChangeNotifier {
  TaskStore(this._repository);

  final TaskRepository _repository;
  final _uuid = const Uuid();

  List<TaskListModel> _lists = [];
  List<TaskModel> _tasks = [];
  String? _activeListId;

  List<TaskListModel> get lists => _lists;
  String? get activeListId => _activeListId;
  TaskListModel? get activeList {
    if (_lists.isEmpty) return null;
    return _lists.firstWhere(
      (l) => l.id == _activeListId,
      orElse: () => _lists.first,
    );
  }

  List<TaskModel> get tasksForActive => _activeListId == null
      ? []
      : _tasks.where((t) => t.listId == _activeListId).toList();

  Future<void> initialize() async {
    await _repository.init();
    _lists = await _repository.loadLists();
    _tasks = await _repository.loadTasks();
    if (_lists.isEmpty) {
      final defaultList = TaskListModel(
        id: _uuid.v4(),
        name: 'My Tasks',
        starred: true,
      );
      _lists = [defaultList];
      _activeListId = defaultList.id;
      await _persist();
    } else {
      _activeListId = _lists.first.id;
    }
    await WidgetService.updateWidget(_tasks, listName: activeList?.name);
  }

  Future<void> setActiveList(String listId) async {
    _activeListId = listId;
    notifyListeners();
  }

  Future<void> addList(String name, {bool starred = false}) async {
    final list = TaskListModel(id: _uuid.v4(), name: name, starred: starred);
    _lists = [..._lists, list];
    _activeListId = list.id;
    await _persist();
    await _persist();
    notifyListeners();
    // Widget usually displays tasks, but we update to be safe if logic depends on lists
    await WidgetService.updateWidget(_tasks, listName: activeList?.name);
  }

  Future<void> updateList(TaskListModel list) async {
    _lists = _lists.map((l) => l.id == list.id ? list : l).toList();
    await _persist();
    notifyListeners();
    await WidgetService.updateWidget(_tasks, listName: activeList?.name);
  }

  Future<void> deleteList(String id) async {
    _lists = _lists.where((l) => l.id != id).toList();
    _tasks = _tasks.where((t) => t.listId != id).toList();
    if (_activeListId == id && _lists.isNotEmpty) {
      _activeListId = _lists.first.id;
    }
    await _persist();
    notifyListeners();
    await WidgetService.updateWidget(_tasks, listName: activeList?.name);
  }

  Future<void> addTask({
    required String title,
    String? description,
    DateTime? dueAt,
    DateTime? reminderAt,
    List<SubTask> subtasks = const [],
    List<Attachment> attachments = const [],
    bool starred = false,
  }) async {
    final now = DateTime.now();
    final task = TaskModel(
      id: _uuid.v4(),
      listId: _activeListId!,
      title: title,
      description: description,
      dueAt: dueAt,
      reminderAt: reminderAt,
      subtasks: subtasks,
      attachments: attachments,
      starred: starred,
      createdAt: now,
      updatedAt: now,
    );
    _tasks = [..._tasks, task];
    await _persist();
    await _schedule(task);
    notifyListeners();
    await WidgetService.updateWidget(_tasks, listName: activeList?.name);
  }

  Future<void> updateTask(TaskModel task) async {
    _tasks = _tasks.map((t) => t.id == task.id ? task : t).toList();
    await _persist();
    await _schedule(task);
    notifyListeners();
    await WidgetService.updateWidget(_tasks, listName: activeList?.name);
  }

  Future<void> deleteTask(String taskId) async {
    _tasks = _tasks.where((t) => t.id != taskId).toList();
    await _persist();
    await NotificationService.instance.cancel(taskId.hashCode);
    notifyListeners();
    await WidgetService.updateWidget(_tasks, listName: activeList?.name);
  }

  Future<void> toggleCompletion(TaskModel task) async {
    final updated = task.copyWith(
      completed: !task.completed,
      updatedAt: DateTime.now(),
    );
    await updateTask(updated);
  }

  Future<void> toggleStar(TaskModel task) async {
    final updated = task.copyWith(
      starred: !task.starred,
      updatedAt: DateTime.now(),
    );
    await updateTask(updated);
  }

  List<TaskModel> tasksForList(String listId) =>
      _tasks.where((t) => t.listId == listId).toList();

  Future<void> refresh() async {
    await _repository.init();
    _lists = await _repository.loadLists();
    _lists = await _repository.loadLists();
    _tasks = await _repository.loadTasks();
    await WidgetService.updateWidget(_tasks, listName: activeList?.name);
    if (_lists.isEmpty) {
      _activeListId = null;
    } else if (_activeListId == null ||
        !_lists.any((l) => l.id == _activeListId)) {
      _activeListId = _lists.first.id;
    }
    notifyListeners();
  }

  Future<void> reorderLists(List<TaskListModel> newOrder) async {
    _lists = newOrder;
    if (_lists.isEmpty) {
      _activeListId = null;
    } else if (_activeListId == null ||
        !_lists.any((l) => l.id == _activeListId)) {
      _activeListId = _lists.first.id;
    }
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    await _repository.persist(lists: _lists, tasks: _tasks);
  }

  Future<void> _schedule(TaskModel task) async {
    if (task.reminderAt != null && task.reminderAt!.isAfter(DateTime.now())) {
      await NotificationService.instance.scheduleDeadlineNotification(
        id: task.id.hashCode,
        title: task.title,
        body: task.description ?? 'Reminder for ${task.title}',
        scheduledAt: task.reminderAt!,
      );
    }
  }
}
