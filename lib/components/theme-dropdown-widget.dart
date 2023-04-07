import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/enums/themes.dart';
import 'package:mobile/domain/services/theme-service.dart';

class ThemeDropdown extends StatefulWidget {
  final MobileThemeMode mode;
  const ThemeDropdown({
    Key? key,
    required this.mode,
  }) : super(key: key);

  @override
  State<ThemeDropdown> createState() => _ThemeDropdownState();
}

class _ThemeDropdownState extends State<ThemeDropdown> {
  late MobileThemeMode mode;
  final _settingsService = GetIt.I.get<SettingsService>();

  late MobileTheme? dropdownValue;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mode = widget.mode;
    dropdownValue = _settingsService.getCurrentTheme(mode);
  }

  @override
  Widget build(BuildContext context) {


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
        _settingsService.switchMainTheme(mode, value!);
      },
    );
  }
}
