import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/task_models.dart';
import '../state/task_store.dart';
import '../utils/date_formatters.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({super.key, required this.task, required this.onEdit});

  final TaskModel task;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final store = context.read<TaskStore>();
    final scheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: scheme.errorContainer,
        child: Icon(Icons.delete, color: scheme.onErrorContainer),
      ),
      onDismissed: (_) => store.deleteTask(task.id),
      child: InkWell(
        onLongPress: () async {
          HapticFeedback.mediumImpact();
          _showQuickActions(context, store);
        },
        onTap: onEdit,
        child: ListTile(
          leading: Checkbox(
            value: task.completed,
            onChanged: (_) => store.toggleCompletion(task),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.completed ? TextDecoration.lineThrough : null,
              color: task.completed
                  ? scheme.onSurfaceVariant
                  : scheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((task.description ?? '').isNotEmpty)
                Text(
                  task.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (task.dueAt != null)
                    _buildChip(context, Icons.event, formatDate(task.dueAt!)),
                  if (task.reminderAt != null)
                    _buildChip(
                      context,
                      Icons.alarm,
                      formatDateTime(task.reminderAt!),
                    ),
                  if (task.subtasks.isNotEmpty)
                    _buildChip(
                      context,
                      Icons.check_circle,
                      '${task.subtasks.where((s) => s.completed).length}/${task.subtasks.length}',
                    ),
                  if (task.attachments.isNotEmpty)
                    _buildChip(
                      context,
                      Icons.attachment,
                      '${task.attachments.length} file',
                    ),
                ],
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(task.starred ? Icons.star : Icons.star_border),
            onPressed: () {
              HapticFeedback.selectionClick();
              store.toggleStar(task);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, IconData icon, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      avatar: Icon(icon, size: 16, color: scheme.onSurfaceVariant),
      label: Text(label),
      side: BorderSide(color: scheme.outlineVariant),
    );
  }

  void _showQuickActions(BuildContext context, TaskStore store) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  onEdit();
                },
              ),
              ListTile(
                leading: Icon(task.starred ? Icons.star : Icons.star_border),
                title: Text(task.starred ? 'Unstar' : 'Star'),
                onTap: () {
                  Navigator.pop(context);
                  store.toggleStar(task);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  store.deleteTask(task.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
