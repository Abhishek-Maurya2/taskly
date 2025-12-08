import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:settings_tiles/settings_tiles.dart';

import '../models/task_models.dart';
import '../state/task_store.dart';
import '../widgets/task_editor_sheet.dart';
import 'settings_page.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<TaskStore>();
    final lists = store.lists;
    if (lists.isEmpty) {
      return const Scaffold(body: _EmptyState());
    }

    final activeId =
        store.activeListId ?? (lists.isNotEmpty ? lists.first.id : null);
    final initialIndex = activeId == null
        ? 0
        : lists.indexWhere((l) => l.id == activeId).clamp(0, lists.length - 1);

    return DefaultTabController(
      length: lists.length,
      initialIndex: initialIndex,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, _) {
            return [
              SliverAppBar.large(
                titleSpacing: 0,
                backgroundColor: Theme.of(context).colorScheme.surface,
                scrolledUnderElevation: 1,
                title: const Text('Tasks'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsPage()),
                    ),
                  ),
                ],
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  child: Container(
                    color: Theme.of(context).colorScheme.surface,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TabBar(
                            isScrollable: true,
                            labelStyle: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                            tabs: [
                              for (final list in lists)
                                Tab(
                                  icon: list.starred
                                      ? const Icon(Icons.star, size: 16)
                                      : null,
                                  text: list.name,
                                ),
                            ],
                            onTap: (index) =>
                                store.setActiveList(lists[index].id),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          tooltip: 'New list',
                          onPressed: () => _promptList(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              for (final list in lists)
                _TaskListView(listId: list.id, key: ValueKey(list.id)),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openEditor(context),
          label: const Text('Add task'),
          icon: const Icon(Icons.add),
        ),
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

  final String listId;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<TaskStore>();
    final tasks = store.tasksForList(listId);
    if (tasks.isEmpty) {
      return const _EmptyState();
    }

    List<TaskModel> sorted(List<TaskModel> items) {
      final copy = [...items];
      copy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return copy;
    }

    final activeTasks = sorted(tasks.where((t) => !t.completed).toList());
    final completedTasks = sorted(tasks.where((t) => t.completed).toList());

    List<Widget> buildTaskTiles(
      List<TaskModel> source, {
      required bool completed,
    }) {
      final tiles = <Widget>[];
      final colorScheme = Theme.of(context).colorScheme;

      for (final task in source) {
        final subTiles = <Widget>[];
        if (task.subtasks.isNotEmpty) {
          for (final sub in task.subtasks) {
            subTiles.add(
              Padding(
                padding: const EdgeInsets.only(left: 12.0, bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      sub.completed
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 18,
                      color: sub.completed ? Colors.green : colorScheme.outline,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        sub.title,
                        style: sub.completed
                            ? const TextStyle(
                                decoration: TextDecoration.lineThrough,
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        }

        tiles.add(
          SettingExpandableListTile(
            icon: Icon(
              task.starred
                  ? Icons.star
                  : (!completed ? Icons.circle_outlined : Icons.check),
              color: completed ? Colors.green : colorScheme.onSurface,
            ),
            title: Text(
              task.title,
              style: completed
                  ? const TextStyle(decoration: TextDecoration.lineThrough)
                  : null,
            ),
            description: task.description?.isNotEmpty == true
                ? Text(task.description!)
                : null,
            trailing: const Icon(Icons.edit_outlined),
            onTap: () => _openEditor(context, task),
            subItems: subTiles,
            initiallyExpanded: true,
          ),
        );
      }

      return tiles;
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      children: [
        if (activeTasks.isNotEmpty)
          SettingSection(
            styleTile: true,
            title: const SettingSectionTitle('Active tasks', noPadding: true),
            tiles: buildTaskTiles(activeTasks, completed: false),
          ),
        if (completedTasks.isNotEmpty) ...[
          const SizedBox(height: 12),
          SettingSection(
            styleTile: true,
            title: const SettingSectionTitle(
              'Completed tasks',
              noPadding: true,
            ),
            tiles: buildTaskTiles(completedTasks, completed: true),
          ),
        ],
        if (activeTasks.isEmpty && completedTasks.isEmpty) const _EmptyState(),
      ],
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

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => kToolbarHeight;

  @override
  double get maxExtent => kToolbarHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
