import 'package:flutter/material.dart';
import 'package:mobile/domain/enums/themes.dart';
import 'package:rxdart/rxdart.dart';

class ThemeService {
  Subject<bool> notifyThemeChange = PublishSubject();
  String currentTheme = 'light';
  bool isDynamic = false;

  switchTheme(String value) {
    isDynamic = value == 'dynamic';
    if (!isDynamic) currentTheme = value;

    notifyThemeChange.add(true);
  }

  ThemeData getTheme() {
    if (isDynamic) return Themes.light;

    switch (currentTheme) {
      case "dark":
        return Themes.dark;
      case "light":
        return Themes.light;
      default:
        return Themes.light;
    }
  }

  ThemeData getDarkMode() {
    return Themes.dark;
  }

  get themes => Themes.list;
}
