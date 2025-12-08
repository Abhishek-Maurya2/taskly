import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/preferences_helper.dart';
import 'package:settings_tiles/settings_tiles.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../notifiers/unit_settings_notifier.dart';
import 'package:provider/provider.dart';
import '../utils/theme_controller.dart';
import 'package:restart_app/restart_app.dart';
import '../utils/snack_util.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  bool _showTile = PreferencesHelper.getBool("usingCustomSeed") ?? false;
  bool _useCustomTile = PreferencesHelper.getBool("DynamicColors") == true
      ? false
      : true;
  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final currentMode = themeController.themeMode;

    final isSupported = themeController.isDynamicColorSupported;

    final colorTheme = Theme.of(context).colorScheme;

    final optionsTheme = {"Auto": "Auto", "Dark": "Dark", "Light": "Light"};

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: Text(
              'Appearance',
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
                  title: const SettingSectionTitle(
                    'Appearance',
                    noPadding: true,
                  ),
                  tiles: [
                    SettingSingleOptionTile(
                      icon: Icon(Symbols.routine),
                      title: const Text('Theme mode'),
                      dialogTitle: 'Theme mode',
                      value: SettingTileValue(
                        optionsTheme[currentMode == ThemeMode.light
                            ? "Light"
                            : currentMode == ThemeMode.system
                            ? "Auto"
                            : "Dark"]!,
                      ),
                      options: optionsTheme.values.toList(),
                      initialOption:
                          optionsTheme[currentMode == ThemeMode.light
                              ? "Light"
                              : currentMode == ThemeMode.system
                              ? "Auto"
                              : "Dark"]!,
                      onSubmitted: (value) {
                        setState(() {
                          final selectedKey = optionsTheme.entries
                              .firstWhere((e) => e.value == value)
                              .key;
                          PreferencesHelper.setString("AppTheme", selectedKey);
                          themeController.setThemeMode(
                            selectedKey == "Dark"
                                ? ThemeMode.dark
                                : selectedKey == "Auto"
                                ? ThemeMode.system
                                : ThemeMode.light,
                          );
                        });
                      },
                    ),
                    SettingSwitchTile(
                      enabled: _useCustomTile,
                      icon: _showTile
                          ? GestureDetector(
                              onTap: () {
                                Color selectedColor =
                                    PreferencesHelper.getColor(
                                      "CustomMaterialColor",
                                    ) ??
                                    Colors.blue;

                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  showDragHandle: true,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(28),
                                    ),
                                  ),
                                  builder: (context) {
                                    return Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: EdgeInsets.only(
                                        top: 0,
                                        bottom:
                                            MediaQuery.of(
                                              context,
                                            ).padding.bottom +
                                            10,
                                      ),
                                      child: StatefulBuilder(
                                        builder: (context, setModalState) {
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ColorPicker(
                                                color: selectedColor,
                                                onColorChanged: (Color color) {
                                                  setModalState(() {
                                                    selectedColor = color;
                                                  });
                                                },
                                                pickersEnabled:
                                                    const <
                                                      ColorPickerType,
                                                      bool
                                                    >{
                                                      ColorPickerType.primary:
                                                          false,
                                                      ColorPickerType.accent:
                                                          false,
                                                      ColorPickerType.both:
                                                          true,
                                                      ColorPickerType.custom:
                                                          false,
                                                      ColorPickerType.wheel:
                                                          false,
                                                    },
                                                spacing: 6,
                                                runSpacing: 6,
                                                subheading: Divider(),
                                                borderRadius: 50,
                                              ),
                                              SizedBox(height: 12),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                    ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    OutlinedButton(
                                                      onPressed: () {
                                                        Navigator.of(
                                                          context,
                                                        ).pop();
                                                      },
                                                      child: Text(
                                                        'Cancel',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                    FilledButton(
                                                      onPressed: () {
                                                        Navigator.of(
                                                          context,
                                                        ).pop();
                                                        setState(() {
                                                          PreferencesHelper.setColor(
                                                            "CustomMaterialColor",
                                                            selectedColor,
                                                          );
                                                          Provider.of<
                                                                ThemeController
                                                              >(
                                                                context,
                                                                listen: false,
                                                              )
                                                              .setSeedColor(
                                                                selectedColor,
                                                              );
                                                        });
                                                      },
                                                      child: Text(
                                                        'Save',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                width: 24,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: PreferencesHelper.getColor(
                                    "CustomMaterialColor",
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    width: 1,
                                    color: colorTheme.outline,
                                  ),
                                ),
                              ),
                            )
                          : Icon(Symbols.colorize, fill: 1, weight: 500),
                      title: const Text("Use custom color"),
                      toggled:
                          PreferencesHelper.getBool("usingCustomSeed") ?? false,
                      onChanged: (value) {
                        setState(() {
                          PreferencesHelper.setBool("usingCustomSeed", value);
                          if (value == true) {
                            Provider.of<ThemeController>(
                              context,
                              listen: false,
                            ).setSeedColor(
                              PreferencesHelper.getColor(
                                    "CustomMaterialColor",
                                  ) ??
                                  Colors.blue,
                            );
                          } else {
                            Provider.of<ThemeController>(
                              context,
                              listen: false,
                            ).setSeedColor(
                              PreferencesHelper.getColor("weatherThemeColor") ??
                                  Colors.blue,
                            );
                          }
                        });
                        _showTile = value;
                      },
                    ),
                    SettingSwitchTile(
                      icon: Icon(Symbols.brush, fill: 1, weight: 500),
                      title: const Text('Use expressive palette'),
                      toggled:
                          PreferencesHelper.getBool("useExpressiveVariant") ??
                          false,
                      onChanged: (value) {
                        context.read<UnitSettingsNotifier>().updateColorVariant(
                          value,
                        );
                        setState(() {});
                      },
                    ),
                    SettingSwitchTile(
                      enabled: isSupported
                          ? _showTile
                                ? false
                                : true
                          : false,
                      icon: Icon(Symbols.wallpaper, fill: 1, weight: 500),
                      title: const Text("Dynamic colors"),
                      description: Text(
                        "Use system wallpaper colors${isSupported ? "" : " (Android 12+)"}",
                      ),
                      toggled:
                          PreferencesHelper.getBool("DynamicColors") ?? false,
                      onChanged: (value) async {
                        final themeController = context.read<ThemeController>();

                        PreferencesHelper.setBool("DynamicColors", value);

                        if (value) {
                          await themeController.loadDynamicColors();
                        } else {
                          Provider.of<ThemeController>(
                            context,
                            listen: false,
                          ).setSeedColor(
                            PreferencesHelper.getColor("weatherThemeColor") ??
                                Colors.blue,
                          );
                        }
                        setState(() {
                          if (value) {
                            _useCustomTile = false;
                          } else {
                            _useCustomTile = true;
                          }
                        });
                      },
                    ),
                    SettingSwitchTile(
                      icon: Icon(Symbols.palette, fill: 1, weight: 500),
                      title: const Text("Material scheme only"),
                      description: const Text(
                        'Force Material seed scheme even with palette',
                      ),
                      toggled:
                          PreferencesHelper.getBool("OnlyMaterialScheme") ??
                          false,
                      onChanged: (value) {
                        PreferencesHelper.setBool("OnlyMaterialScheme", value);
                        setState(() {
                          SnackUtil.showSnackBar(
                            context: context,
                            message: "Restart required to apply changes",
                            actionLabel: "Restart",
                            duration: Duration(seconds: 30),
                            onActionPressed: () {
                              Restart.restartApp();
                            },
                          );
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 200),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
