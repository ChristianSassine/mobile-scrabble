import 'package:flutter/material.dart';

enum MobileTheme {
  Light("light"),
  Dark("dark"),
  Dynamic("dynamic");

  const MobileTheme(this.value);
  final String value;
}

class Themes {
  static get light => ThemeData(
    primarySwatch: Colors.green,
  );

  static get dark => ThemeData(
    primarySwatch: Colors.green,
    brightness: Brightness.dark,
  );
}

