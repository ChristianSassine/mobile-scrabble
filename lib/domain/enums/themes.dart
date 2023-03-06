import 'package:flutter/material.dart';

enum MobileTheme {
  Light("setting.light"),
  Dark("setting.dark"),
  Dynamic("setting.dynamic");

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
