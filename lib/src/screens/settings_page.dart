import 'package:flutter/material.dart';
import 'package:settings_tiles/settings_tiles.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../services/notification_service.dart';
import 'appearance_screen.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Settings'),
            titleSpacing: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            scrolledUnderElevation: 1,
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                SettingSection(
                  styleTile: true,
                  tiles: [
                    SettingActionTile(
                      icon: iconContainer(
                        Symbols.format_paint,
                        isLight ? Color(0xfff8e287) : Color(0xff534600),
                        isLight ? Color(0xff534600) : Color(0xfff8e287),
                      ),
                      title: const Text("Appearance"),
                      description: const Text("Appearance Sub"),
                      onTap: () async {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AppearanceScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10),
                SettingSection(
                  styleTile: true,
                  title: const SettingSectionTitle(
                    'Notifications',
                    noPadding: true,
                  ),
                  tiles: [
                    SettingActionTile(
                      icon: iconContainer(
                        Symbols.notifications_active_rounded,
                        isLight ? Color(0xffffdcc5) : Color(0xff6d390b),
                        isLight ? Color(0xff6d390b) : Color(0xffffdcc5),
                      ),
                      title: const Text('Clear scheduled notifications'),
                      description: const Text('Cancel all pending reminders.'),
                      trailing: const Icon(Icons.delete_outline),
                      onTap: () => NotificationService.instance.cancelAll(),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                SettingSection(
                  styleTile: true,
                  title: const SettingSectionTitle('Info', noPadding: true),
                  tiles: [
                    SettingTextTile(
                      icon: iconContainer(
                        Symbols.info,
                        isLight ? Color(0xffe6deff) : Color(0xff493e76),
                        isLight ? Color(0xff493e76) : Color(0xffe6deff),
                      ),
                      title: Text('Expressive layout'),
                      description: Text(
                        'Settings now use Material 3 styled tiles.',
                      ),
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

Widget iconContainer(IconData icon, Color color, Color onColor) {
  return Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(50),
      color: color,
    ),
    child: Icon(icon, fill: 1, weight: 500, color: onColor),
  );
}
