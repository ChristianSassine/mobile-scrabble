import 'package:flutter/material.dart';
import 'package:mobile/domain/enums/themes.dart';
import 'package:rxdart/rxdart.dart';

class ThemeService {
  Subject<bool> notifyThemeChange = PublishSubject();
  MobileTheme currentTheme = MobileTheme.Light;
  MobileTheme lightMode = MobileTheme.Light;
  MobileTheme darkMode = MobileTheme.Dark;
  bool isDynamic = false;

  switchMainTheme(MobileTheme value) {
    isDynamic = value == MobileTheme.Dynamic;
    if (!isDynamic) currentTheme = value;

    notifyThemeChange.add(true);
  }

  ThemeData getTheme() {
    if (isDynamic) return _extractTheme(lightMode);
    return _extractTheme(currentTheme);
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
