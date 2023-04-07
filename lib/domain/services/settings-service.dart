import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/enums/themes.dart';
import 'package:mobile/domain/models/user-auth-models.dart';
import 'package:mobile/domain/services/http-handler-service.dart';
import 'package:rxdart/rxdart.dart';

class SettingsService {
  final _httpService = GetIt.I.get<HttpHandlerService>();

  Subject<bool> notifySettingsChange = PublishSubject();

  void loadConfig(SettingsInfo info) {
    mainTheme = info.themeInfo.mainTheme;
    lightMode = info.themeInfo.lightTheme;
    darkMode = info.themeInfo.darkTheme;
    isDynamic = info.themeInfo.isDynamic;
    currentLocale = Locale(info.language);
    notifySettingsChange.add(true);
  }

  Future<void> saveConfig() async {
    await _saveThemes();
    await _saveLanguage();
  }

  // Language Settings

  // Default config
  Locale currentLocale = const Locale("fr");

  void switchLocale(context, Locale newLocale) {
    currentLocale = newLocale;
    final language = currentLocale.languageCode;
    debugPrint(language);
    _saveLanguage();
    notifySettingsChange.add(true);
  }

  Future<void> _saveLanguage() async {
    final language = currentLocale.languageCode;
    await _httpService.modifyLanguageRequest(language);
  }

  // Themes Settings

  // Default config
  MobileTheme mainTheme = MobileTheme.Light;
  MobileTheme lightMode = MobileTheme.Light;
  MobileTheme darkMode = MobileTheme.Dark;
  bool isDynamic = false;

  Future<void> _saveThemes() async {
    final themeConfig = {
      "mainTheme": mainTheme.value,
      "lightTheme": lightMode.value,
      "darkTheme": darkMode.value,
      "isDynamic": isDynamic
    };
    await _httpService.modifyThemeRequest(themeConfig);
  }

  void switchThemeMode(bool dynamic) {
    isDynamic = dynamic;
    notifySettingsChange.add(true);
    _saveThemes();
  }

  void switchMainTheme(MobileThemeMode mode, MobileTheme value) {
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
    _saveThemes();
  }

  MobileTheme getCurrentTheme(MobileThemeMode mode) {
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
