import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mobile/components/language-dropdown-widget.dart';
import 'package:mobile/components/theme-dropdown-widget.dart';

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
                  height: 100,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            "${FlutterI18n.translate(context, "setting.theme")}: "),
                        SizedBox(width: 5),
                        ThemeDropdown(),
                        SizedBox(width: 30),
                        Text(
                            "${FlutterI18n.translate(context, "setting.language")}: "),
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
