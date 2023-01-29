import 'package:flutter/material.dart';
import 'package:mobile/screens/menu-screen.dart';

void main() {
  runApp(const PolyScrabble());
}

class PolyScrabble extends StatelessWidget {
  const PolyScrabble({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PolyScrabble 110',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MenuPage(title: 'PolyScrabble 101 - Prototype'),
    );
  }
}
