import 'package:flutter/material.dart';
import 'package:mobile/screens/menu-screen.dart';
import 'package:get_it/get_it.dart';
import 'domain/services/chatbox-service.dart';

void setUp(){
  GetIt.I.registerLazySingleton<ChatboxService>(() => ChatboxService());
}

void main() {
  setUp();
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
      home: const MenuScreen(title: 'PolyScrabble 101 - Prototype'),
    );
  }
}
