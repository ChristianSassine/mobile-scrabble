import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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
  String? dropdownValue;

  @override
  Widget build(BuildContext context) {
    dropdownValue ??= themeService.currentTheme;

    return DropdownButton<String>(
      value: dropdownValue,
      elevation: 16,
      underline: Container(
        height: 2,
        color: Colors.black,
      ),
      items: themeService.themes.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? value) {
        setState(() {
          dropdownValue = value;
        });
        themeService.switchTheme(value!);
      },
    );
  }
}
