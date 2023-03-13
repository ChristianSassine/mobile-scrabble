import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class LanguageService {
  Locale currentLocale = const Locale("fr");

  switchLocale(context, newLocale) {
    currentLocale = newLocale;
    FlutterI18n.refresh(context, newLocale);
  }
}
