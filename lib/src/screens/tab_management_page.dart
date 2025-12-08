import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/task_models.dart';
import '../state/task_store.dart';

class TabManagementPage extends StatefulWidget {
  const TabManagementPage({super.key});

  @override
  State<TabManagementPage> createState() => _TabManagementPageState();
}

class _TabManagementPageState extends State<TabManagementPage> {
  List<TaskListModel> _workingLists = const [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final store = context.read<TaskStore>();
    _workingLists = List<TaskListModel>.from(store.lists);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<TaskStore>();
    _workingLists = List<TaskListModel>.from(store.lists);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Manage tabs'),
            centerTitle: false,
            backgroundColor: Theme.of(context).colorScheme.surface,
            scrolledUnderElevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, size: 24),
              tooltip: 'Back',
              onPressed: () {
                HapticFeedback.selectionClick();
                Navigator.of(context).maybePop();
              },
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                fixedSize: Size(20, 50),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                'Drag to reorder list tabs. The first list shows after Starred.',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: true,
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _workingLists.length,
              itemBuilder: (context, index) {
                final list = _workingLists[index];
                final isActive = store.activeListId == list.id;
                return Card(
                  key: ValueKey(list.id),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: IconButton(
                      icon: Icon(
                        list.starred ? Icons.star : Icons.star_border,
                        color: list.starred
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      tooltip: list.starred ? 'Unfavorite' : 'Favorite',
                      onPressed: () async {
                        HapticFeedback.selectionClick();
                        final updated = list.copyWith(starred: !list.starred);
                        await store.updateList(updated);
                      },
                    ),
                    title: Text(list.name),
                    subtitle: isActive ? const Text('Current') : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          tooltip: 'Rename list',
                          onPressed: () => _renameList(context, list),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Delete list',
                          onPressed: _workingLists.length <= 1
                              ? null
                              : () => _deleteList(context, list),
                        ),
                        const Icon(Icons.drag_indicator),
                      ],
                    ),
                  ),
                );
              },
              onReorder: (oldIndex, newIndex) async {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = _workingLists.removeAt(oldIndex);
                  _workingLists.insert(newIndex, item);
                });
                await store.reorderLists(
                  List<TaskListModel>.from(_workingLists),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busy ? null : () => _addList(context),
        icon: const Icon(Icons.add),
        label: const Text('New list'),
      ),
    );
  }

  Future<void> _addList(BuildContext context) async {
    final controller = TextEditingController();
    bool starred = false;

    final shouldCreate = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New list'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: 'List name'),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setState) {
                  return SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Mark as favorite'),
                    value: starred,
                    onChanged: (v) => setState(() => starred = v),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) return;
                Navigator.pop(context, true);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    if (shouldCreate == true) {
      if (!context.mounted) return;
      final taskStore = context.read<TaskStore>();
      setState(() => _busy = true);
      final name = controller.text.trim();
      await taskStore.addList(name, starred: starred);
      if (context.mounted) setState(() => _busy = false);
    }
  }

  Future<void> _renameList(BuildContext context, TaskListModel list) async {
    final controller = TextEditingController(text: list.name);
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename list'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'List name'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) return;
                Navigator.pop(context, true);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (shouldSave == true) {
      if (!context.mounted) return;
      final taskStore = context.read<TaskStore>();
      final name = controller.text.trim();
      await taskStore.updateList(list.copyWith(name: name));
    }
  }

  Future<void> _deleteList(BuildContext context, TaskListModel list) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete list?'),
          content: Text(
            'Deleting "${list.name}" will remove its tasks. This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      if (!context.mounted) return;
      final taskStore = context.read<TaskStore>();
      await taskStore.deleteList(list.id);
    }
  }
}
