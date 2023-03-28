import 'package:flutter/material.dart';

class SnackBarFactory {
  static SnackBar greenSnack(String text) {
    return SnackBar(
      content: Text(
        text,
        textAlign: TextAlign.center,
      ),
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.green,
    );
  }

  static SnackBar redSnack(String text) {
    return SnackBar(
      content: Text(
        text,
        textAlign: TextAlign.center,
      ),
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.red,
    );
  }
}
