import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/services/auth-service.dart';
import 'package:mobile/screens/menu-screen.dart';
import 'package:mobile/domain/services/chat-service.dart';
import 'package:socket_io_client/socket_io_client.dart';


Future<void> setup() async {
  final getIt = GetIt.instance;

  String envFile = kDebugMode ? 'development.env' : 'production.env';

  // kDebugMode = APK, so hardcoding it for now
  envFile = 'production.env';

  await dotenv.load(fileName: envFile);
  var serverAddress = dotenv.env["SERVER_URL"];

  getIt.registerLazySingleton<Socket>(() =>
      io(serverAddress, OptionBuilder().setTransports(["websocket"]).build()));

  Socket socket = getIt<Socket>();
  socket.onConnect((_) {
    if (kDebugMode) {
      print('Socket connection established');
    }
  });

  getIt.registerLazySingleton<ChatService>(() => ChatService());
  getIt.registerLazySingleton<AuthService>(() => AuthService());
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
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      home: const MenuScreen(title: 'PolyScrabble 101 - Prototype'),
    );
  }
}
