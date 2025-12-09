import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:settings_tiles/settings_tiles.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../services/notification_service.dart';
import '../services/update_service.dart';
import 'appearance_screen.dart';
import 'tab_management_page.dart';
import 'widget_preview_screen.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _checkingUpdate = false;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(
              'Settings',
              style: GoogleFonts.oswald(
                textStyle: Theme.of(context).textTheme.headlineMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
            titleSpacing: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
            scrolledUnderElevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, size: 20),
              tooltip: 'Back',
              onPressed: () {
                HapticFeedback.selectionClick();
                Navigator.of(context).maybePop();
              },
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                minimumSize: Size(30, 40),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
              ),
            ),
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
                  title: const SettingSectionTitle('Widgets', noPadding: true),
                  tiles: [
                    SettingActionTile(
                      icon: iconContainer(
                        Symbols.widgets,
                        isLight
                            ? const Color(0xffe5f2ff)
                            : const Color(0xff0c2e4a),
                        isLight
                            ? const Color(0xff0c2e4a)
                            : const Color(0xffe5f2ff),
                      ),
                      title: const Text('Customize widgets'),
                      description: const Text(
                        'Preview and adjust home widget style.',
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const WidgetPreviewScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                SettingSection(
                  styleTile: true,
                  title: const SettingSectionTitle(
                    'Tabs & lists',
                    noPadding: true,
                  ),
                  tiles: [
                    SettingActionTile(
                      icon: iconContainer(
                        Symbols.tab,
                        isLight
                            ? const Color(0xffd1e8ff)
                            : const Color(0xff0f4c81),
                        isLight
                            ? const Color(0xff0f4c81)
                            : const Color(0xffd1e8ff),
                      ),
                      title: const Text('Manage tabs & lists'),
                      description: const Text(
                        'Reorder list tabs and pick your focus.',
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TabManagementPage(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                SettingSection(
                  styleTile: true,
                  title: const SettingSectionTitle('Updates', noPadding: true),
                  tiles: [
                    SettingActionTile(
                      icon: iconContainer(
                        Symbols.system_update,
                        isLight
                            ? const Color(0xffd1f7ff)
                            : const Color(0xff0a3b4d),
                        isLight
                            ? const Color(0xff0a3b4d)
                            : const Color(0xffd1f7ff),
                      ),
                      title: const Text('Check for updates'),
                      description: const Text(
                        'Fetch latest APK from GitHub releases.',
                      ),
                      trailing: _checkingUpdate
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : null,
                      onTap: () {
                        if (_checkingUpdate) return;
                        _handleUpdateCheck();
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
                SizedBox(height: 10),
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

  Future<void> _handleUpdateCheck() async {
    setState(() => _checkingUpdate = true);
    try {
      final info = await const UpdateService().checkForUpdate();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) {
          final hasUpdate = info.hasUpdate && info.downloadUrl.isNotEmpty;
          return AlertDialog(
            title: Text(
              hasUpdate ? 'Update available' : 'Up to date',
              style: GoogleFonts.oswald(
                textStyle: Theme.of(context).textTheme.titleLarge,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current: ${info.currentVersion}'),
                Text('Latest: ${info.latestVersion}'),
                const SizedBox(height: 12),
                if (info.releaseNotes != null && info.releaseNotes!.isNotEmpty)
                  SizedBox(
                    height: 140,
                    child: SingleChildScrollView(
                      child: Text(info.releaseNotes!),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              if (hasUpdate)
                FilledButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('Open download'),
                  onPressed: () {
                    Navigator.pop(context);
                    _launchUrl(info.downloadUrl);
                  },
                ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update check failed: $e')));
    } finally {
      if (mounted) setState(() => _checkingUpdate = false);
    }
  }

  void _launchUrl(String url) {
    launchUrlString(url, mode: LaunchMode.externalApplication);
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
