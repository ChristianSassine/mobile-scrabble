import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/screens/menu-screen.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'services/chatbox-service.dart';
import 'package:get_it/get_it.dart';

Future<void> setup() async {
  final getIt = GetIt.instance;
  getIt.registerLazySingleton<ChatboxService>(() => ChatboxService());

  await dotenv.load(fileName: 'development.env');
  var serverAddress = dotenv.env["SERVER_URL"];

  getIt.registerSingleton(io(serverAddress));
}

Future<void> main() async {
  await setup();
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
