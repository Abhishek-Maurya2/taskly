import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:settings_tiles/settings_tiles.dart';

import '../services/notification_service.dart';
import '../state/task_store.dart';
import '../utils/theme_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<TaskStore>();
    final activeList = store.activeList;
    final theme = context.watch<ThemeController>();
    final colorScheme = Theme.of(context).colorScheme;
    final themeLabel = switch (theme.themeMode) {
      ThemeMode.dark => 'Dark',
      ThemeMode.light => 'Light',
      ThemeMode.system => 'System',
    };

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: 170,
            backgroundColor: colorScheme.surface,
            scrolledUnderElevation: 1,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.fadeTitle,
              ],
              titlePadding: const EdgeInsetsDirectional.only(
                start: 16,
                bottom: 16,
              ),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Settings'),
                  if (activeList != null)
                    Text(
                      'Active list • ${activeList.name}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                ],
              ),
              background: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primaryContainer,
                      colorScheme.surfaceContainerHighest,
                    ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 18, bottom: 26),
                    child: Icon(
                      activeList?.starred == true
                          ? Icons.star_rounded
                          : Icons.settings,
                      color: colorScheme.onPrimaryContainer,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                SettingSection(
                  styleTile: true,
                  title: const SettingSectionTitle('Appearance', noPadding: true),
                  tiles: [
                    SettingSingleOptionTile(
                      icon: const SettingTileIcon(Icons.brightness_6_outlined),
                      title: const Text('Theme'),
                      dialogTitle: 'Theme',
                      options: const ['System', 'Light', 'Dark'],
                      initialOption: themeLabel,
                      value: SettingTileValue(themeLabel),
                      onSubmitted: (value) {
                        switch (value) {
                          case 'Light':
                            theme.setThemeMode(ThemeMode.light);
                          case 'Dark':
                            theme.setThemeMode(ThemeMode.dark);
                          default:
                            theme.setThemeMode(ThemeMode.system);
                        }
                      },
                    ),
                    SettingSwitchTile(
                      icon: const SettingTileIcon(Icons.palette_outlined),
                      title: const Text('Dynamic color'),
                      description: Text(
                        theme.supportsDynamicColor
                            ? 'Use device wallpaper colors'
                            : 'Not supported on this device',
                      ),
                      toggled: theme.useDynamicColor,
                      enabled: theme.supportsDynamicColor,
                      onChanged: theme.setUseDynamicColor,
                    ),
                    SettingColorTile(
                      icon: const SettingTileIcon(Icons.color_lens_outlined),
                      title: const Text('Accent color'),
                      description: const Text('Pick a custom seed color'),
                      dialogTitle: 'Accent color',
                      initialColor: theme.seedColor,
                      enableOpacity: false,
                      onSubmitted: (color) => theme.setSeedColor(color),
                    ),
                  ],
                ),
                SettingSection(
                  styleTile: true,
                  title: const SettingSectionTitle('Lists', noPadding: true),
                  tiles: [
                    SettingSwitchTile(
                      icon: const SettingTileIcon(Icons.star_rounded),
                      title: const Text('Star active list'),
                      description: const Text('Mark the current list as a favorite.'),
                      toggled: activeList?.starred ?? false,
                      enabled: activeList != null,
                      onChanged: (value) {
                        final list = store.activeList;
                        if (list == null) return;
                        store.updateList(list.copyWith(starred: value));
                      },
                    ),
                  ],
                ),
                SettingSection(
                  styleTile: true,
                  title: const SettingSectionTitle('Notifications', noPadding: true),
                  tiles: [
                    SettingActionTile(
                      icon: const SettingTileIcon(Icons.notifications_active_outlined),
                      title: const Text('Clear scheduled notifications'),
                      description: const Text('Cancel all pending reminders.'),
                      trailing: const Icon(Icons.delete_outline),
                      onTap: () => NotificationService.instance.cancelAll(),
                    ),
                  ],
                ),
                SettingSection(
                  styleTile: true,
                  title: const SettingSectionTitle('Info', noPadding: true),
                  tiles: const [
                    SettingTextTile(
                      icon: SettingTileIcon(Icons.info_outline),
                      title: Text('Expressive layout'),
                      description: Text('Settings now use Material 3 styled tiles.'),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
