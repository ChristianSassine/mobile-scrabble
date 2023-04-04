import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/components/theme-dropdown-widget.dart';
import 'package:mobile/domain/enums/themes.dart';
import 'package:mobile/domain/services/theme-service.dart';

class ThemesSettings extends StatefulWidget {
  const ThemesSettings({
    Key? key,
  }) : super(key: key);

  @override
  State<ThemesSettings> createState() => _ThemesSettingsState();
}

class _ThemesSettingsState extends State<ThemesSettings> {
  bool isDynamic = false;
  final _themeService = GetIt.I.get<ThemeService>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("${FlutterI18n.translate(context, "setting.theme")} "),
        Row(
          children: [
            Text(FlutterI18n.translate(context, "setting.static")),
            Switch(
                value: isDynamic,
                onChanged: (bool value) {
                  setState(() {
                    isDynamic = value;
                    _themeService.switchMode(value);
                  });
                }),
            Text(FlutterI18n.translate(context, "setting.dynamic")),
          ],
        ),
        Row(
          children: [
            Text("${FlutterI18n.translate(context, "setting.main_mode")} : "),
            const ThemeDropdown(mode: MobileThemeMode.Main,),
          ],
        ),
        Row(
          children: [
            Text("${FlutterI18n.translate(context, "setting.light_mode")} : "),
            const ThemeDropdown(mode: MobileThemeMode.Light),
          ],
        ),
        Row(
          children: [
            Text("${FlutterI18n.translate(context, "setting.dark_mode")} : "),
            const ThemeDropdown(mode: MobileThemeMode.Dark),
          ],
        ),
      ],
    );
  }
}
