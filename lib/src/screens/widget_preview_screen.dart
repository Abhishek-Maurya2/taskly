import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/task_models.dart';
import '../state/task_store.dart';

class WidgetPreviewScreen extends StatefulWidget {
  const WidgetPreviewScreen({super.key});

  @override
  State<WidgetPreviewScreen> createState() => _WidgetPreviewScreenState();
}

enum _WidgetStyle { compact, expanded }

class _WidgetPreviewScreenState extends State<WidgetPreviewScreen> {
  String? _selectedListId;
  bool _includeCompleted = false;
  double _maxItems = 5;
  _WidgetStyle _style = _WidgetStyle.compact;

  @override
  void initState() {
    super.initState();
    final store = context.read<TaskStore>();
    _selectedListId = store.activeListId ?? (store.lists.isNotEmpty ? store.lists.first.id : null);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<TaskStore>();
    final lists = store.lists;
    final tasks = _tasksForPreview(store);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(
              'Widgets',
              style: GoogleFonts.oswald(
                textStyle: Theme.of(context).textTheme.headlineMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: false,
            backgroundColor: colorScheme.surface,
            scrolledUnderElevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, size: 20),
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).maybePop(),
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerHighest,
                minimumSize: const Size(30, 40),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Customize your home widgets and preview how they will look.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  _buildListPicker(lists),
                  const SizedBox(height: 12),
                  _buildStyleSelector(colorScheme),
                  const SizedBox(height: 12),
                  _buildToggles(),
                  const SizedBox(height: 12),
                  _buildMaxItemsSlider(),
                  const SizedBox(height: 20),
                  Text(
                    'Preview',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _WidgetPreviewCard(
                    tasks: tasks,
                    style: _style,
                    colorScheme: colorScheme,
                    includeCompleted: _includeCompleted,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListPicker(List<TaskListModel> lists) {
    return DropdownButtonFormField<String>(
      // ignore: deprecated_member_use
      initialValue: _selectedListId,
      decoration: const InputDecoration(labelText: 'List for widget'),
      items: lists
          .map(
            (l) => DropdownMenuItem(
              value: l.id,
              child: Text(l.name),
            ),
          )
          .toList(),
      onChanged: (value) => setState(() => _selectedListId = value),
    );
  }

  Widget _buildStyleSelector(ColorScheme scheme) {
    return Row(
      children: [
        ChoiceChip(
          label: const Text('Compact'),
          selected: _style == _WidgetStyle.compact,
          onSelected: (_) => setState(() => _style = _WidgetStyle.compact),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Expanded'),
          selected: _style == _WidgetStyle.expanded,
          onSelected: (_) => setState(() => _style = _WidgetStyle.expanded),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.widgets_outlined, size: 18),
              const SizedBox(width: 6),
              Text(_style == _WidgetStyle.compact ? 'Small' : 'Large'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggles() {
    return Column(
      children: [
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Include completed tasks'),
          value: _includeCompleted,
          onChanged: (v) => setState(() => _includeCompleted = v),
        ),
      ],
    );
  }

  Widget _buildMaxItemsSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Max items'),
            const Spacer(),
            Text(_maxItems.toInt().toString()),
          ],
        ),
        Slider(
          value: _maxItems,
          min: 3,
          max: 10,
          divisions: 7,
          label: _maxItems.toInt().toString(),
          onChanged: (v) => setState(() => _maxItems = v),
        ),
      ],
    );
  }

  List<TaskModel> _tasksForPreview(TaskStore store) {
    final listId = _selectedListId;
    final base = listId == null
        ? <TaskModel>[]
        : store.tasksForList(listId).where((t) => _includeCompleted || !t.completed).toList();
    final limited = base.take(_maxItems.toInt()).toList();
    if (limited.isNotEmpty) return limited;
    // Fallback demo content
    return [
      TaskModel(
        id: 'demo-1',
        listId: listId ?? 'demo',
        title: 'Plan sprint goals',
        description: 'Prioritize backlog and owners',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        starred: true,
      ),
      TaskModel(
        id: 'demo-2',
        listId: listId ?? 'demo',
        title: 'Design review',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}

class _WidgetPreviewCard extends StatelessWidget {
  const _WidgetPreviewCard({
    required this.tasks,
    required this.style,
    required this.colorScheme,
    required this.includeCompleted,
  });

  final List<TaskModel> tasks;
  final _WidgetStyle style;
  final ColorScheme colorScheme;
  final bool includeCompleted;

  @override
  Widget build(BuildContext context) {
    final cardColor = style == _WidgetStyle.compact
        ? colorScheme.surfaceContainerHighest
        : colorScheme.primaryContainer;
    final textColor = style == _WidgetStyle.compact
        ? colorScheme.onSurface
        : colorScheme.onPrimaryContainer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.widgets, color: textColor),
              const SizedBox(width: 8),
              Text(
                style == _WidgetStyle.compact ? 'Compact widget' : 'Expanded widget',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              Text(
                '${tasks.length} items',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: textColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tasks.map(
            (task) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    task.completed ? Icons.check_circle : Icons.circle_outlined,
                    size: 18,
                    color: task.completed
                        ? colorScheme.secondary
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if ((task.description ?? '').isNotEmpty)
                          Text(
                            task.description!,
                            maxLines: style == _WidgetStyle.compact ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: textColor.withValues(alpha: 0.9),
                                ),
                          ),
                      ],
                    ),
                  ),
                  if (task.starred)
                    Icon(Icons.star, size: 18, color: colorScheme.tertiary),
                ],
              ),
            ),
          ),
          if (tasks.isEmpty)
            Text(
              includeCompleted
                  ? 'No tasks available for this list.'
                  : 'No active tasks. Try including completed items.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor),
            ),
        ],
      ),
    );
  }
}
