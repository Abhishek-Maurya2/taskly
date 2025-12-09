import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/task_store.dart';
import 'task_editor_screen.dart';

class WidgetActionHandler extends StatefulWidget {
  final String action;

  const WidgetActionHandler({super.key, required this.action});

  @override
  State<WidgetActionHandler> createState() => _WidgetActionHandlerState();
}

class _WidgetActionHandlerState extends State<WidgetActionHandler> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleAction();
    });
  }

  void _handleAction() {
    if (widget.action == 'openlists') {
      _showListSelection();
    } else if (widget.action == 'opentask') {
      // For add task, we might just want to replace this route with the editor
      // or push the editor and then pop this handler when editor closes.
      _openTaskEditor();
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _openTaskEditor() async {
    // We replace the transparent handler with the Editor,
    // or push execution.
    // If we want "independent" feel, just pushing is fine.
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const TaskEditorScreen()),
    );
  }

  void _showListSelection() {
    final store = context.read<TaskStore>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true, // Allow it to be taller if needed
      builder: (ctx) {
        // Use a separate builder context or capture the store
        return ListSelectionSheet(
          store: store,
          onSelected: (id) {
            store.setActiveList(id);
            Navigator.pop(ctx); // Close sheet
          },
        );
      },
    ).then((_) {
      // When sheet closes, close this transparent screen
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Transparent scaffold
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox.expand(),
    );
  }
}

class ListSelectionSheet extends StatelessWidget {
  final TaskStore store;
  final Function(String) onSelected;

  const ListSelectionSheet({
    super.key,
    required this.store,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              'Select List',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 8),
          ...store.lists.map(
            (list) => ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 4,
              ),
              title: Text(list.name, style: const TextStyle(fontSize: 16)),
              leading: Icon(
                list.id == store.activeListId
                    ? Icons.check_circle
                    : Icons.circle_outlined,
                color: list.id == store.activeListId
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onTap: () => onSelected(list.id),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
