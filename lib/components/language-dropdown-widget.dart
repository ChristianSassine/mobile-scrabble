import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/services/settings-service.dart';

class LanguageDropdown extends StatefulWidget {
  const LanguageDropdown({
    Key? key,
  }) : super(key: key);

  @override
  State<LanguageDropdown> createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  final _settingsService = GetIt.I.get<SettingsService>();
  String? dropdownValue;

  // Those labels don't need to be translated (We want the language name in the language itself)
  List<DropdownMenuItem<String>> availableLanguages =
      <DropdownMenuItem<String>>[
    const DropdownMenuItem<String>(value: "fr", child: Text("FR")),
    const DropdownMenuItem<String>(value: "en", child: Text("EN")),
  ];

  void _changeLanguage(Locale locale) {
    _settingsService.switchLocale(context, locale);
    setState(() {
      dropdownValue = locale.languageCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    dropdownValue ??= FlutterI18n.currentLocale(context)!.languageCode;

    return DropdownButton<String>(
      value: dropdownValue,
      elevation: 16,
      underline: Container(
        height: 2,
        color: Colors.black,
      ),
      items: availableLanguages,
      onChanged: (String? value) {
        _changeLanguage(Locale(value!));
      },
    );
  }
}
