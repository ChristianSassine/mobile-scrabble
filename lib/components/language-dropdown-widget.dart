import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/enums/themes.dart';
import 'package:mobile/domain/extensions/string-extensions.dart';
import 'package:mobile/domain/services/language-service.dart';
import 'package:mobile/domain/services/theme-service.dart';

class LanguageDropdown extends StatefulWidget {
  final Function() notifyParent;

  const LanguageDropdown({
    Key? key, required this.notifyParent
  }) : super(key: key);

  @override
  State<LanguageDropdown> createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  final _languageService = GetIt.I.get<LanguageService>();
  String? dropdownValue;

  // Those labels don't need to be translated (We want the language name in the language itself)
  List<DropdownMenuItem<String>> availableLanguages =
      <DropdownMenuItem<String>>[
    const DropdownMenuItem<String>(value: "fr", child: Text("Français")),
    const DropdownMenuItem<String>(value: "en", child: Text("English")),
  ];

  void _changeLanguage(Locale locale) {
    _languageService.switchLocale(context, locale);
    setState(() {
      dropdownValue = locale.languageCode;
    });
    widget.notifyParent(); //Refresh the parent widget
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
