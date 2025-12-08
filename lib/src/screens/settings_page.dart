import 'package:flutter/material.dart';
import 'package:settings_tiles/settings_tiles.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../services/notification_service.dart';
import 'appearance_screen.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool toggled = true;
  bool checked = false;
  String singleOption = 'Option 1';
  List<String> multiOptions = const ['Option 1'];
  double sliderValue = 5;
  double customSliderValue = 7;
  final List<double> customSliderValues = const [1, 7, 30];
  Color color = Colors.blue;
  String textValue = 'Hello world';

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
                SizedBox(height: 16),
                SettingSection(
                  styleTile: true,
                  title: const SettingSectionTitle(
                    'Tile gallery',
                    noPadding: true,
                  ),
                  tiles: [
                    const SettingTextTile(
                      icon: SettingTileIcon(Icons.abc),
                      title: Text('Text tile'),
                      description: Text('Plain informational tile'),
                     
                    ),
                    SettingActionTile(
                      icon: const SettingTileIcon(Icons.touch_app),
                      title: const Text('Action tile'),
                      description: const Text('Taps trigger an action'),
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Action tile tapped'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      ),
                    ),
                    SettingSwitchTile(
                      icon: const SettingTileIcon(Icons.toggle_on),
                      title: const Text('Switch tile'),
                      description: const Text('Toggle on/off state'),
                      toggled: toggled,
                      onChanged: (value) => setState(() => toggled = value),
                    ),
                    SettingCheckboxTile(
                      icon: const SettingTileIcon(Icons.check_box),
                      title: const Text('Checkbox tile'),
                      description: const Text('Supports tri-state'),
                      checked: checked,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => checked = value);
                      },
                    ),
                    SettingSingleOptionTile(
                      icon: const SettingTileIcon(Icons.radio_button_checked),
                      title: const Text('Single option'),
                      value: SettingTileValue(singleOption),
                      description: const Text('Pick exactly one'),
                      dialogTitle: 'Choose one',
                      options: const ['Option 1', 'Option 2', 'Option 3'],
                      initialOption: singleOption,
                      onSubmitted: (value) =>
                          setState(() => singleOption = value),
                    ),
                    SettingMultipleOptionsTile(
                      icon: const SettingTileIcon(Icons.checklist),
                      title: const Text('Multiple options'),
                      value: SettingTileValue(multiOptions.join(' | ')),
                      description: const Text('Pick many'),
                      dialogTitle: 'Choose items',
                      options: const ['Option 1', 'Option 2', 'Option 3'],
                      initialOptions: multiOptions,
                      onSubmitted: (value) =>
                          setState(() => multiOptions = value),
                    ),
                    SettingTextFieldTile(
                      icon: const SettingTileIcon(Icons.text_fields),
                      title: const Text('Text field'),
                      value: SettingTileValue(textValue),
                      description: const Text('Opens a text input dialog'),
                      dialogTitle: 'Edit text',
                      initialText: textValue,
                      onSubmitted: (value) => setState(() => textValue = value),
                    ),
                    SettingSliderTile(
                      icon: const SettingTileIcon(Icons.linear_scale),
                      title: const Text('Slider'),
                      value: SettingTileValue(sliderValue.toStringAsFixed(0)),
                      description: const Text('Continuous numeric choice'),
                      dialogTitle: 'Adjust value',
                      min: 1,
                      max: 10,
                      divisions: 9,
                      initialValue: sliderValue,
                      onSubmitted: (value) =>
                          setState(() => sliderValue = value),
                    ),
                    SettingCustomSliderTile(
                      icon: const SettingTileIcon(Icons.stacked_line_chart),
                      title: const Text('Custom slider'),
                      value: SettingTileValue(
                        customSliderValue.toStringAsFixed(0),
                      ),
                      description: const Text('Discrete preset values'),
                      dialogTitle: 'Choose interval',
                      values: customSliderValues,
                      initialValue: customSliderValue,
                      label: (value) {
                        switch (value) {
                          case 1:
                            return 'Day';
                          case 7:
                            return 'Week';
                          case 30:
                            return 'Month';
                          default:
                            return value.toStringAsFixed(0);
                        }
                      },
                      onSubmitted: (value) =>
                          setState(() => customSliderValue = value),
                    ),
                    SettingColorTile(
                      icon: const SettingTileIcon(Icons.color_lens),
                      title: const Text('Color'),
                      description: const Text('Pick a color'),
                      dialogTitle: 'Choose color',
                      initialColor: color,
                      onSubmitted: (value) => setState(() => color = value),
                    ),
                    SettingAboutTile(
                      applicationIcon: const Icon(Icons.apps),
                      applicationName: 'Taskly',
                      applicationVersion: 'v1.0.0',
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
