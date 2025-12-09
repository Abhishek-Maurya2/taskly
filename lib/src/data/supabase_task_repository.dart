import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_models.dart';
import 'task_repository.dart';

class SupabaseTaskRepository implements TaskRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<void> init() async {
    // No explicit initialization needed for Supabase client here as it's initialized in main
  }

  @override
  Future<List<TaskListModel>> loadLists() async {
    final response = await _client.from('lists').select().order('created_at');
    final data = response as List<dynamic>;
    return data.map((e) => _mapListFromSupabase(e)).toList();
  }

  TaskListModel _mapListFromSupabase(Map<String, dynamic> map) {
    return TaskListModel(
      id: map['id'],
      name: map['name'],
      starred: map['starred'] ?? false,
    );
  }

  @override
  Future<List<TaskModel>> loadTasks() async {
    final response = await _client.from('tasks').select();
    final data = response as List<dynamic>;
    return data.map((e) => _mapTaskFromSupabase(e)).toList();
  }

  TaskModel _mapTaskFromSupabase(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      listId: map['list_id'],
      title: map['title'],
      description: map['description'],
      completed: map['completed'] ?? false,
      starred: map['starred'] ?? false,
      dueAt: map['due_at'] != null ? DateTime.parse(map['due_at']) : null,
      reminderAt: map['reminder_at'] != null
          ? DateTime.parse(map['reminder_at'])
          : null,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : DateTime.now(),
      subtasks:
          (map['subtasks'] as List?)
              ?.map((x) => SubTask.fromMap(x as Map<String, dynamic>))
              .toList() ??
          [],
      attachments:
          (map['attachments'] as List?)
              ?.map((x) => Attachment.fromMap(x as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  Future<void> addList(TaskListModel list) async {
    await _client.from('lists').insert({
      'id': list.id,
      'name': list.name,
      'starred': list.starred,
      'user_id': _client.auth.currentUser?.id,
    });
  }

  @override
  Future<void> updateList(TaskListModel list) async {
    await _client
        .from('lists')
        .update({'name': list.name, 'starred': list.starred})
        .eq('id', list.id);
  }

  @override
  Future<void> deleteList(String id) async {
    await _client.from('lists').delete().eq('id', id);
  }

  @override
  Future<void> addTask(TaskModel task) async {
    await _client.from('tasks').insert({
      'id': task.id,
      'list_id': task.listId,
      'title': task.title,
      'description': task.description,
      'completed': task.completed,
      'starred': task.starred,
      'due_at': task.dueAt?.toIso8601String(),
      'reminder_at': task.reminderAt?.toIso8601String(),
      'updated_at': task.updatedAt.toIso8601String(),
      'created_at': task.createdAt.toIso8601String(),
      'subtasks': task.subtasks.map((s) => s.toMap()).toList(),
      'attachments': task.attachments.map((a) => a.toMap()).toList(),
      'user_id': _client.auth.currentUser?.id,
    });
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await _client
        .from('tasks')
        .update({
          'list_id': task.listId,
          'title': task.title,
          'description': task.description,
          'completed': task.completed,
          'starred': task.starred,
          'due_at': task.dueAt?.toIso8601String(),
          'reminder_at': task.reminderAt?.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'subtasks': task.subtasks.map((s) => s.toMap()).toList(),
          'attachments': task.attachments.map((a) => a.toMap()).toList(),
        })
        .eq('id', task.id);
  }

  @override
  Future<void> deleteTask(String id) async {
    await _client.from('tasks').delete().eq('id', id);
  }

  @override
  Future<void> persist({
    required List<TaskListModel> lists,
    required List<TaskModel> tasks,
  }) async {
    // No-op or throw warning.
    // We do not want to iterate and upsert everything in a simple persist call for Cloud.
    // If used, it might be legacy call.
    print(
      'Warning: Bulk persist called on SupabaseRepository. Ignoring to prevent overwrites.',
    );
  }
}
