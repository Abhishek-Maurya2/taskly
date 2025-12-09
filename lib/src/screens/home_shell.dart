import 'package:flutter/material.dart';
import 'package:expressive_loading_indicator/expressive_loading_indicator.dart';
import 'package:flutter/services.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:settings_tiles/settings_tiles.dart';

import '../models/task_models.dart';
import '../state/task_store.dart';
import 'task_editor_screen.dart';
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
    final tabsLength = lists.length + 1; // +1 for Starred tab
    final initialIndex = activeId == null
        ? (tabsLength > 1 ? 1 : 0)
        : (lists.indexWhere((l) => l.id == activeId) + 1).clamp(
            0,
            tabsLength - 1,
          );

    return DefaultTabController(
      length: tabsLength,
      initialIndex: initialIndex,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, _) {
            return [
              SliverAppBar.large(
                backgroundColor: Theme.of(context).colorScheme.surface,
                title: Text(
                  'Tasks',
                  style: GoogleFonts.oswald(
                    textStyle: Theme.of(context).textTheme.headlineLarge,
                    fontWeight: FontWeight.w600,
                    fontSize: 40,
                    height: 1,
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      ),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        child: ClipOval(
                          child: SizedBox.expand(
                            child: Image.asset(
                              'assets/images/avatar.jpg',
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.person,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(52),
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add),
                          tooltip: 'New list',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(
                            width: 40,
                            height: 40,
                          ),
                          onPressed: () => _promptList(context),
                        ),
                        Expanded(
                          child: TabBar(
                            isScrollable: true,
                            tabAlignment: TabAlignment.start,
                            labelPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                            indicatorPadding: EdgeInsets.zero,
                            indicatorSize: TabBarIndicatorSize.label,
                            dividerColor: Colors.transparent,
                            labelStyle: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                            labelColor: Theme.of(context).colorScheme.primary,
                            tabs: [
                              const Tab(
                                icon: Icon(Icons.star),
                                iconMargin: EdgeInsets.zero,
                              ),
                              for (final list in lists) Tab(text: list.name),
                            ],
                            onTap: (index) {
                              if (index == 0) return;
                              store.setActiveList(lists[index - 1].id);
                            },
                          ),
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
              const _StarredTaskListView(),
              for (final list in lists)
                _TaskListView(listId: list.id, key: ValueKey(list.id)),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openEditor(context),
          label: const Text('Add task'),
          icon: const Icon(Icons.add),
          isExtended: true,
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
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TaskEditorScreen(existing: existing)),
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
    final activeTasks = _sorted(tasks.where((t) => !t.completed).toList());
    final completedTasks = _sorted(tasks.where((t) => t.completed).toList());

    return _PullToRefresh(
      onRefresh: () => store.refresh(),
      child: ListView(
        padding: const EdgeInsets.only(left: 2, right: 2, top: 14, bottom: 100),
        children: [
          if (activeTasks.isNotEmpty)
            SettingSection(
              styleTile: true,
              title: const SettingSectionTitle('Active tasks', noPadding: true),
              tiles: _buildTaskTiles(
                context,
                store,
                activeTasks,
                completed: false,
              ),
            ),
          if (completedTasks.isNotEmpty) ...[
            const SizedBox(height: 12),
            SettingSection(
              styleTile: true,
              title: const SettingSectionTitle(
                'Completed tasks',
                noPadding: true,
              ),
              tiles: _buildTaskTiles(
                context,
                store,
                completedTasks,
                completed: true,
              ),
            ),
          ],
          if (activeTasks.isEmpty && completedTasks.isEmpty)
            const _EmptyState(),
        ],
      ),
    );
  }
}

class _StarredTaskListView extends StatelessWidget {
  const _StarredTaskListView();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<TaskStore>();
    final allTasks = store.lists
        .expand((list) => store.tasksForList(list.id))
        .where((task) => task.starred)
        .toList();

    if (allTasks.isEmpty) {
      return const _EmptyState();
    }

    final activeTasks = _sorted(allTasks.where((t) => !t.completed).toList());
    final completedTasks = _sorted(allTasks.where((t) => t.completed).toList());

    return _PullToRefresh(
      onRefresh: () => store.refresh(),
      child: ListView(
        padding: const EdgeInsets.only(left: 2, right: 2, top: 14, bottom: 100),
        children: [
          if (activeTasks.isNotEmpty)
            SettingSection(
              styleTile: true,
              title: const SettingSectionTitle(
                'Starred tasks',
                noPadding: true,
              ),
              tiles: _buildTaskTiles(
                context,
                store,
                activeTasks,
                completed: false,
              ),
            ),
          if (completedTasks.isNotEmpty) ...[
            const SizedBox(height: 12),
            SettingSection(
              styleTile: true,
              title: const SettingSectionTitle(
                'Completed starred tasks',
                noPadding: true,
              ),
              tiles: _buildTaskTiles(
                context,
                store,
                completedTasks,
                completed: true,
              ),
            ),
          ],
          if (activeTasks.isEmpty && completedTasks.isEmpty)
            const _EmptyState(),
        ],
      ),
    );
  }
}

List<TaskModel> _sorted(List<TaskModel> items) {
  final copy = [...items];
  copy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return copy;
}

String _dueLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final diff = target.difference(today).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Tomorrow';
  if (diff == -1) return 'Yesterday';
  return '${date.month}/${date.day}';
}

Future<void> _openTaskEditor(BuildContext context, TaskModel task) {
  return Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => TaskEditorScreen(existing: task)));
}

List<Widget> _buildTaskTiles(
  BuildContext context,
  TaskStore store,
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
            padding: const EdgeInsets.only(
              left: 12.0,
              bottom: 12,
              top: 12,
              right: 12,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final updatedSub = sub.copyWith(completed: !sub.completed);
                final newSubtasks = task.subtasks
                    .map((s) => s.id == sub.id ? updatedSub : s)
                    .toList();
                final updatedTask = task.copyWith(
                  subtasks: newSubtasks,
                  updatedAt: DateTime.now(),
                );
                await store.updateTask(updatedTask);
              },
              child: Row(
                children: [
                  Icon(
                    sub.completed ? Icons.check : Icons.radio_button_unchecked,
                    size: 24,
                    color: sub.completed
                        ? colorScheme.primary
                        : colorScheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      sub.title,
                      style: TextStyle(
                        decoration: sub.completed
                            ? TextDecoration.lineThrough
                            : null,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    final chips = <Widget>[];
    if (task.reminderAt != null) {
      final time = TimeOfDay.fromDateTime(
        task.reminderAt!.toLocal(),
      ).format(context);
      chips.add(
        Chip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.alarm, size: 16),
              const SizedBox(width: 6),
              Text(time),
            ],
          ),
        ),
      );
    }
    if (task.dueAt != null) {
      chips.add(
        Chip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.schedule, size: 16),
              const SizedBox(width: 6),
              Text(_dueLabel(task.dueAt!.toLocal())),
            ],
          ),
        ),
      );
    }
    if (task.attachments.isNotEmpty) {
      final count = task.attachments.length;
      chips.add(
        Chip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.attach_file, size: 16),
              const SizedBox(width: 6),
              Text('Media $count'),
            ],
          ),
        ),
      );
    }

    tiles.add(
      SettingExpandableListTile(
        icon: InkResponse(
          radius: 22,
          onTap: () async {
            HapticFeedback.selectionClick();
            await store.toggleCompletion(task);
          },
          child: Icon(
            !completed ? Icons.circle_outlined : Icons.check,
            color: completed ? colorScheme.primary : colorScheme.onSurface,
          ),
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
        trailing: IconButton(
          icon: Icon(task.starred ? Icons.star : Icons.star_border),
          tooltip: task.starred ? 'Unstar task' : 'Star task',
          onPressed: () {
            HapticFeedback.selectionClick();
            store.toggleStar(task);
          },
        ),
        onTap: () => _openTaskEditor(context, task),
        subItems: subTiles,
        chips: chips,
        initiallyExpanded: true,
      ),
    );
  }

  return tiles;
}

class _PullToRefresh extends StatefulWidget {
  const _PullToRefresh({required this.child, required this.onRefresh});

  final Widget child;
  final Future<void> Function() onRefresh;

  @override
  State<_PullToRefresh> createState() => _PullToRefreshState();
}

class _PullToRefreshState extends State<_PullToRefresh> {
  bool _refreshing = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        RefreshIndicator(
          color: Colors.transparent,
          backgroundColor: Colors.transparent,
          strokeWidth: 0.0001,
          onRefresh: () async {
            setState(() => _refreshing = true);
            try {
              await widget.onRefresh();
            } finally {
              if (mounted) setState(() => _refreshing = false);
            }
          },
          child: widget.child,
        ),
        IgnorePointer(
          child: AnimatedOpacity(
            opacity: _refreshing ? 1 : 0,
            duration: const Duration(milliseconds: 150),
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).shadowColor.withValues(alpha: 0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: ExpressiveLoadingIndicator(
                    color: Theme.of(context).colorScheme.primary,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                      maxWidth: 28,
                      maxHeight: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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
