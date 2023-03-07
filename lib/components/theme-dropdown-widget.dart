import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/enums/themes.dart';
import 'package:mobile/domain/services/theme-service.dart';

class ThemeDropdown extends StatefulWidget {
  const ThemeDropdown({
    Key? key,
  }) : super(key: key);

  @override
  State<ThemeDropdown> createState() => _ThemeDropdownState();
}

class _ThemeDropdownState extends State<ThemeDropdown> {
  final themeService = GetIt.I.get<ThemeService>();
  MobileTheme? dropdownValue;

  @override
  Widget build(BuildContext context) {
    dropdownValue ??= themeService.currentTheme;

    return DropdownButton<MobileTheme>(
      value: dropdownValue,
      elevation: 16,
      underline: Container(
        height: 2,
        color: Colors.black,
      ),
      items: MobileTheme.values.map<DropdownMenuItem<MobileTheme>>((
          MobileTheme theme) {
        return DropdownMenuItem<MobileTheme>(
          value: theme,
          child: Text(FlutterI18n.translate(context, theme.value)),
        );
      }).toList(),
      onChanged: (MobileTheme? value) {
        setState(() {
          dropdownValue = value;
        });
        themeService.switchTheme(value!);
      },
    );
  }
}
