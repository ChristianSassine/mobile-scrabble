import 'package:flutter/material.dart';

enum MobileThemeMode {
  Main("setting.main"),
  Dark("setting.dark"),
  Light("setting.light");

  const MobileThemeMode(this.value);
  final String value;
}

enum MobileTheme {
  Light("setting.light"),
  Dark("setting.dark");

  const MobileTheme(this.value);

  final String value;
}

class Themes {
  static get light =>
      ThemeData(primarySwatch: Colors.green);

  static get dark => ThemeData(
      primarySwatch: Colors.green,
      brightness: Brightness.dark);
}
