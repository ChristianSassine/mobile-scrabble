import 'package:flutter/material.dart';
import 'package:mobile/domain/enums/themes.dart';
import 'package:rxdart/rxdart.dart';

class ThemeService {
  Subject<bool> notifyThemeChange = PublishSubject();
  String currentTheme = 'light';

  switchTheme(String theme) {
    currentTheme = theme;
    notifyThemeChange.add(true);
  }

  ThemeData getTheme(){
    switch (currentTheme)
    {
      case "dark":
        return Themes.dark;
      case "light":
        return Themes.light;
      default:
        return Themes.light;
    }
  }

  get themes => Themes.list;
}
