import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/enums/themes.dart';
import 'package:mobile/domain/extensions/string-extensions.dart';
import 'package:mobile/domain/services/theme-service.dart';

class ThemeDropdown extends StatefulWidget {
  final MobileThemeMode mode;
  const ThemeDropdown({
    Key? key,
    required MobileThemeMode this.mode,
  }) : super(key: key);

  @override
  State<ThemeDropdown> createState() => _ThemeDropdownState();
}

class _ThemeDropdownState extends State<ThemeDropdown> {
  MobileThemeMode? mode;
  final themeService = GetIt.I.get<ThemeService>();

  MobileTheme? dropdownValue;

  @override
  Widget build(BuildContext context) {
    mode ??= widget.mode;
    dropdownValue ??= themeService.getCurrentTheme(mode!);

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
        themeService.switchMainTheme(mode!, value!);
      },
    );
  }
}
