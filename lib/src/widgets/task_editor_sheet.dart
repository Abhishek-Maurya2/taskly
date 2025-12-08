import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/task_models.dart';
import '../state/task_store.dart';
import '../utils/date_formatters.dart';

class TaskEditorSheet extends StatefulWidget {
  const TaskEditorSheet({super.key, this.existing});

  final TaskModel? existing;

  @override
  State<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends State<TaskEditorSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _dueAt;
  DateTime? _reminderAt;
  List<SubTask> _subtasks = [];
  List<Attachment> _attachments = [];
  bool _starred = false;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _titleController.text = existing.title;
      _descriptionController.text = existing.description ?? '';
      _dueAt = existing.dueAt;
      _reminderAt = existing.reminderAt;
      _subtasks = List<SubTask>.from(existing.subtasks);
      _attachments = List<Attachment>.from(existing.attachments);
      _starred = existing.starred;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 12,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isEditing ? 'Edit task' : 'New task',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(_starred ? Icons.star : Icons.star_border),
                  onPressed: () => setState(() => _starred = !_starred),
                ),
              ],
            ),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Title'),
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(hintText: 'Description'),
              maxLines: null,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildDateChip(
                  context,
                  icon: Icons.event,
                  label: _dueAt != null ? formatDate(_dueAt!) : 'Due date',
                  onTap: _pickDue,
                ),
                _buildDateChip(
                  context,
                  icon: Icons.alarm,
                  label: _reminderAt != null
                      ? formatDateTime(_reminderAt!)
                      : 'Reminder',
                  onTap: _pickReminder,
                ),
                _buildDateChip(
                  context,
                  icon: Icons.attachment,
                  label: _attachments.isEmpty
                      ? 'Add file'
                      : '${_attachments.length} attachment',
                  onTap: _pickAttachment,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SubtasksEditor(
              subtasks: _subtasks,
              onChanged: (value) => setState(() => _subtasks = value),
              uuid: _uuid,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _save,
                  child: Text(isEditing ? 'Save' : 'Add'),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildDateChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InputChip(
      label: Text(label),
      avatar: Icon(icon, size: 18, color: scheme.primary),
      onPressed: onTap,
      selected: label != 'Due date' && label != 'Reminder',
    );
  }

  Future<void> _pickDue() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      initialDate: _dueAt ?? now,
    );
    if (selectedDate == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueAt ?? DateTime.now()),
    );
    setState(() {
      _dueAt = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        time?.hour ?? 9,
        time?.minute ?? 0,
      );
    });
  }

  Future<void> _pickReminder() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      initialDate: _reminderAt ?? now,
    );
    if (selectedDate == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reminderAt ?? now),
    );
    setState(() {
      _reminderAt = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        time?.hour ?? 9,
        time?.minute ?? 0,
      );
    });
  }

  Future<void> _pickAttachment() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        setState(() {
          _attachments = [
            ..._attachments,
            Attachment(
              id: _uuid.v4(),
              name: file.name,
              uri: file.path ?? file.name,
            ),
          ];
        });
      }
    } on PlatformException {
      // ignore pick errors but keep UX smooth
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      HapticFeedback.heavyImpact();
      return;
    }
    final store = context.read<TaskStore>();
    if (widget.existing == null) {
      await store.addTask(
        title: title,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        dueAt: _dueAt,
        reminderAt: _reminderAt,
        subtasks: _subtasks,
        attachments: _attachments,
        starred: _starred,
      );
    } else {
      await store.updateTask(
        widget.existing!.copyWith(
          title: title,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          dueAt: _dueAt,
          reminderAt: _reminderAt,
          subtasks: _subtasks,
          attachments: _attachments,
          starred: _starred,
          updatedAt: DateTime.now(),
        ),
      );
    }
    if (mounted) Navigator.pop(context);
  }
}

class _SubtasksEditor extends StatelessWidget {
  const _SubtasksEditor({
    required this.subtasks,
    required this.onChanged,
    required this.uuid,
  });

  final List<SubTask> subtasks;
  final ValueChanged<List<SubTask>> onChanged;
  final Uuid uuid;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Subtasks'),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () =>
                  onChanged([...subtasks, SubTask(id: uuid.v4(), title: '')]),
            ),
          ],
        ),
        for (final sub in subtasks)
          _SubtaskTile(
            key: ValueKey(sub.id),
            subTask: sub,
            onChanged: (updated) {
              final next = subtasks
                  .map((s) => s.id == updated.id ? updated : s)
                  .toList();
              onChanged(next);
            },
            onDelete: () =>
                onChanged(subtasks.where((s) => s.id != sub.id).toList()),
          ),
      ],
    );
  }
}

class _SubtaskTile extends StatelessWidget {
  const _SubtaskTile({
    super.key,
    required this.subTask,
    required this.onChanged,
    required this.onDelete,
  });

  final SubTask subTask;
  final ValueChanged<SubTask> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: subTask.title);
    return Row(
      children: [
        Checkbox(
          value: subTask.completed,
          onChanged: (value) =>
              onChanged(subTask.copyWith(completed: value ?? false)),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Subtask title'),
            onChanged: (value) => onChanged(subTask.copyWith(title: value)),
          ),
        ),
        IconButton(onPressed: onDelete, icon: const Icon(Icons.close)),
      ],
    );
  }
}
