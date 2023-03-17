import 'package:flutter/material.dart';
import 'package:mobile/domain/enums/themes.dart';
import 'package:rxdart/rxdart.dart';

class ThemeService {
  Subject<bool> notifyThemeChange = PublishSubject();
  MobileTheme mainTheme = MobileTheme.Light;
  MobileTheme lightMode = MobileTheme.Light;
  MobileTheme darkMode = MobileTheme.Dark;
  bool isDynamic = false;

  switchMode(bool dynamic) {
    isDynamic = dynamic;
    notifyThemeChange.add(true);
  }

  switchMainTheme(MobileThemeMode mode, MobileTheme value) {
    switch (mode) {
      case MobileThemeMode.Light:
        lightMode = value;
        break;
      case MobileThemeMode.Dark:
        darkMode = value;
        break;
      default:
        mainTheme = value;
    }
    notifyThemeChange.add(true);
  }

  getCurrentTheme(MobileThemeMode mode) {
    switch (mode) {
      case MobileThemeMode.Light:
        return lightMode;
      case MobileThemeMode.Dark:
        return darkMode;
      default:
        return mainTheme;
    }
  }

  ThemeData getTheme() {
    if (isDynamic) return _extractTheme(lightMode);
    return _extractTheme(mainTheme);
  }

  ThemeData getDarkMode() {
    return _extractTheme(darkMode);
  }

  ThemeData _extractTheme(MobileTheme theme) {
    switch (theme) {
      case MobileTheme.Light:
        return Themes.light;
      case MobileTheme.Dark:
        return Themes.dark;
      default:
        return Themes.light;
    }
  }
}
