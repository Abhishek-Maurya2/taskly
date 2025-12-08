import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/notification_service.dart';
import '../state/task_store.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<TaskStore>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Star default list'),
            value: store.activeList?.starred ?? false,
            onChanged: (value) {
              final active = store.activeList;
              if (active == null) return;
              store.updateList(active.copyWith(starred: value));
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Clear scheduled notifications'),
            onTap: () => NotificationService.instance.cancelAll(),
          ),
          const Divider(),
          const ListTile(
            title: Text('Design note'),
            subtitle: Text(
              'Material 3 expressive redesign can be applied later.',
            ),
          ),
        ],
      ),
    );
  }
}
