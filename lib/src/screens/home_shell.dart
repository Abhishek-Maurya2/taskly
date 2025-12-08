import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/task_models.dart';
import '../state/task_store.dart';
import '../widgets/task_editor_sheet.dart';
import '../widgets/task_tile.dart';
import 'settings_page.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<TaskStore>();
    final lists = store.lists;
    final activeId =
        store.activeListId ?? (lists.isNotEmpty ? lists.first.id : null);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            titleSpacing: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            scrolledUnderElevation: 1,
            title: const Text('Tasks'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const SettingsPage())),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  for (final list in lists)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(list.name),
                        selected: list.id == activeId,
                        onSelected: (_) => store.setActiveList(list.id),
                        avatar: list.starred
                            ? const Icon(Icons.star, size: 16)
                            : null,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ActionChip(
                      avatar: const Icon(Icons.add),
                      label: const Text('New list'),
                      onPressed: () => _promptList(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (activeId == null)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(),
            )
          else
            _TaskListView(listId: activeId, key: ValueKey(activeId)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        label: const Text('Add task'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _promptList(BuildContext context) async {
    final controller = TextEditingController();
    final store = context.read<TaskStore>();
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create list'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'List name'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isEmpty) return;
                await store.addList(name);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openEditor(BuildContext context, {TaskModel? existing}) async {
    HapticFeedback.lightImpact();
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => TaskEditorSheet(existing: existing),
    );
  }
}

class _TaskListView extends StatelessWidget {
  const _TaskListView({super.key, required this.listId});

  final String? listId;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<TaskStore>();
    if (listId == null) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: _EmptyState(),
      );
    }
    final tasks = store.tasksForList(listId!);
    if (tasks.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: _EmptyState(),
      );
    }
    tasks.sort((a, b) {
      if (a.starred != b.starred) return b.starred ? 1 : -1;
      if (a.dueAt != null && b.dueAt != null) {
        return a.dueAt!.compareTo(b.dueAt!);
      }
      return a.createdAt.compareTo(b.createdAt);
    });
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final task = tasks[index];
        return TaskTile(task: task, onEdit: () => _openEditor(context, task));
      }, childCount: tasks.length),
    );
  }

  void _openEditor(BuildContext context, TaskModel task) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => TaskEditorSheet(existing: task),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text('No tasks yet'),
          SizedBox(height: 4),
          Text('Add a task to get started'),
        ],
      ),
    );
  }
}
