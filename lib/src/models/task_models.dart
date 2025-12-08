import 'dart:convert';

class TaskListModel {
  final String id;
  final String name;
  final bool starred;

  const TaskListModel({
    required this.id,
    required this.name,
    this.starred = false,
  });

  TaskListModel copyWith({String? id, String? name, bool? starred}) {
    return TaskListModel(
      id: id ?? this.id,
      name: name ?? this.name,
      starred: starred ?? this.starred,
    );
  }

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'starred': starred};
  factory TaskListModel.fromMap(Map<String, dynamic> map) => TaskListModel(
    id: map['id'] as String,
    name: map['name'] as String,
    starred: map['starred'] as bool? ?? false,
  );
}

class Attachment {
  final String id;
  final String name;
  final String uri;

  const Attachment({required this.id, required this.name, required this.uri});

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'uri': uri};
  factory Attachment.fromMap(Map<String, dynamic> map) => Attachment(
    id: map['id'] as String,
    name: map['name'] as String,
    uri: map['uri'] as String,
  );
}

class SubTask {
  final String id;
  final String title;
  final bool completed;

  const SubTask({
    required this.id,
    required this.title,
    this.completed = false,
  });

  SubTask copyWith({String? id, String? title, bool? completed}) => SubTask(
    id: id ?? this.id,
    title: title ?? this.title,
    completed: completed ?? this.completed,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'completed': completed,
  };
  factory SubTask.fromMap(Map<String, dynamic> map) => SubTask(
    id: map['id'] as String,
    title: map['title'] as String,
    completed: map['completed'] as bool? ?? false,
  );
}

class TaskModel {
  final String id;
  final String listId;
  final String title;
  final String? description;
  final bool completed;
  final bool starred;
  final DateTime? dueAt;
  final DateTime? reminderAt;
  final List<SubTask> subtasks;
  final List<Attachment> attachments;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskModel({
    required this.id,
    required this.listId,
    required this.title,
    this.description,
    this.completed = false,
    this.starred = false,
    this.dueAt,
    this.reminderAt,
    this.subtasks = const [],
    this.attachments = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  TaskModel copyWith({
    String? id,
    String? listId,
    String? title,
    String? description,
    bool? completed,
    bool? starred,
    DateTime? dueAt,
    DateTime? reminderAt,
    List<SubTask>? subtasks,
    List<Attachment>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      starred: starred ?? this.starred,
      dueAt: dueAt ?? this.dueAt,
      reminderAt: reminderAt ?? this.reminderAt,
      subtasks: subtasks ?? this.subtasks,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'listId': listId,
    'title': title,
    'description': description,
    'completed': completed,
    'starred': starred,
    'dueAt': dueAt?.toIso8601String(),
    'reminderAt': reminderAt?.toIso8601String(),
    'subtasks': subtasks.map((s) => s.toMap()).toList(),
    'attachments': attachments.map((a) => a.toMap()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory TaskModel.fromMap(Map<String, dynamic> map) => TaskModel(
    id: map['id'] as String,
    listId: map['listId'] as String,
    title: map['title'] as String,
    description: map['description'] as String?,
    completed: map['completed'] as bool? ?? false,
    starred: map['starred'] as bool? ?? false,
    dueAt: map['dueAt'] != null ? DateTime.parse(map['dueAt'] as String) : null,
    reminderAt: map['reminderAt'] != null
        ? DateTime.parse(map['reminderAt'] as String)
        : null,
    subtasks: (map['subtasks'] as List<dynamic>? ?? [])
        .map((e) => SubTask.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList(),
    attachments: (map['attachments'] as List<dynamic>? ?? [])
        .map((e) => Attachment.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList(),
    createdAt: DateTime.parse(map['createdAt'] as String),
    updatedAt: DateTime.parse(map['updatedAt'] as String),
  );

  static String encode(List<TaskModel> tasks) =>
      jsonEncode(tasks.map((t) => t.toMap()).toList());
  static List<TaskModel> decode(String source) {
    final list = jsonDecode(source) as List<dynamic>;
    return list
        .map((e) => TaskModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
