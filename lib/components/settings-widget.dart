import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/components/language-dropdown-widget.dart';
import 'package:mobile/components/theme-dropdown-widget.dart';
import 'package:mobile/domain/services/theme-service.dart';

class Settings extends StatefulWidget {
  Function() notifyParent;

  Settings({Key? key, required this.notifyParent}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ThemesSettings(),
            SizedBox(width: 30),
            VerticalDivider(),
            SizedBox(width: 30),
            Text("${FlutterI18n.translate(context, "setting.language")}: "),
            SizedBox(width: 5),
            LanguageDropdown(notifyParent: () {
              setState(() => {});
              debugPrint(FlutterI18n.currentLocale(context)!.languageCode);
              widget.notifyParent();
            })
          ],
        ),
      ),
    );
  }
}

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
            Text("Static"),
            Switch(
                value: isDynamic,
                onChanged: (bool value) {
                  setState(() {
                    isDynamic = value;
                    _themeService.switchMode(value);
                  });
                }),
            Text("Dynamic"),
          ],
        ),
        Row(
          children: [
            Text("Thème principale : "),
            ThemeDropdown(),
          ],
        ),
        Row(
          children: [
            Text("Thème mode clair : "),
            ThemeDropdown(),
          ],
        ),
        Row(
          children: [
            Text("Thème mode sombre : "),
            ThemeDropdown(),
          ],
        ),
      ],
    );
  }
}
