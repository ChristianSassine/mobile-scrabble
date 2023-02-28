import 'package:flutter/material.dart';
import 'package:mobile/domain/enums/themes.dart';
import 'package:rxdart/rxdart.dart';

class ThemeService {
  Subject<bool> notifyThemeChange = PublishSubject();
  MobileTheme currentTheme = MobileTheme.Light;
  bool isDynamic = false;

  switchTheme(MobileTheme value) {
    isDynamic = value == MobileTheme.Dynamic;
    if (!isDynamic) currentTheme = value;

    notifyThemeChange.add(true);
  }

  ThemeData getTheme() {
    if (isDynamic) return Themes.light;

    switch (currentTheme) {
      case MobileTheme.Light:
        return Themes.dark;
      case MobileTheme.Dark:
        return Themes.light;
      default:
        return Themes.light;
    }
  }

  ThemeData getDarkMode() {
    return Themes.dark;
  }
}
