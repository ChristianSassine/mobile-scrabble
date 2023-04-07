import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/enums/themes.dart';
import 'package:mobile/domain/services/http-handler-service.dart';
import 'package:rxdart/rxdart.dart';

class SettingsService {
  final _httpService = GetIt.I.get<HttpHandlerService>();

  Subject<bool> notifySettingsChange = PublishSubject();

  void loadConfig() {
    // TODO : Implement
  }

  // Language Settings
  Locale currentLocale = const Locale("fr");

  switchLocale(context, newLocale) {
    currentLocale = newLocale;
    FlutterI18n.refresh(context, newLocale);
    final curLanguage = FlutterI18n.currentLocale(context)!.languageCode;
    debugPrint(curLanguage);
    _saveLanguage(curLanguage);
    notifySettingsChange.add(true);
  }

  _saveLanguage(String language){
    _httpService.modifyLanguageRequest(language);
  }

  // Themes Settings
  MobileTheme mainTheme = MobileTheme.Light;
  MobileTheme lightMode = MobileTheme.Light;
  MobileTheme darkMode = MobileTheme.Dark;
  bool isDynamic = false;

  _saveThemes(){
    final themeConfig = {
      "mainTheme" : mainTheme.value,
      "lightTheme" : lightMode.value,
      "darkTheme" : darkMode.value,
      "isDynamic" : isDynamic
    };
    _httpService.modifyThemeRequest(themeConfig);
  }

  switchThemeMode(bool dynamic) {
    isDynamic = dynamic;
    notifySettingsChange.add(true);
    _saveThemes();
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
    _saveThemes();
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
