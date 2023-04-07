import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mobile/domain/enums/themes.dart';
import 'package:rxdart/rxdart.dart';

class SettingsService {
  Subject<bool> notifySettingsChange = PublishSubject();
  MobileTheme mainTheme = MobileTheme.Light;
  MobileTheme lightMode = MobileTheme.Light;
  MobileTheme darkMode = MobileTheme.Dark;
  bool isDynamic = false;

  // Language Settings
  Locale currentLocale = const Locale("fr");

  switchLocale(context, newLocale) {
    currentLocale = newLocale;
    FlutterI18n.refresh(context, newLocale);
    debugPrint(
        FlutterI18n.currentLocale(context)!.languageCode);
    notifySettingsChange.add(true);
  }

  // Themes Settings
  switchThemeMode(bool dynamic) {
    isDynamic = dynamic;
    notifySettingsChange.add(true);
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
    notifySettingsChange.add(true);
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
