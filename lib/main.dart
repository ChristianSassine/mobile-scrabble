import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/services/auth-service.dart';
import 'package:mobile/domain/services/chat-service.dart';
import 'package:mobile/domain/services/game-service.dart';
import 'package:mobile/domain/services/http-handler-service.dart';
import 'package:mobile/domain/services/language-service.dart';
import 'package:mobile/domain/services/room-service.dart';
import 'package:mobile/domain/services/theme-service.dart';
import 'package:mobile/screens/login-screen.dart';
import 'package:socket_io_client/socket_io_client.dart';

Future<void> setup() async {
  final getIt = GetIt.instance;

  String envFile = kDebugMode ? 'development.env' : 'production.env';

  // kDebugMode = APK, so hardcoding it for now
  envFile = 'production.env';

  await dotenv.load(fileName: envFile);
  var serverAddress = dotenv.env["SERVER_URL"];

  getIt.registerLazySingleton<Socket>(() => io(
      serverAddress,
      OptionBuilder()
          .setTransports(["websocket"])
          .disableAutoConnect()
          .build()));

  Socket socket = getIt<Socket>();
  socket.onConnect((_) => debugPrint('Socket connection established'));
  socket.onDisconnect((data) => debugPrint('Socket connection lost'));

  getIt.registerLazySingleton<HttpHandlerService>(
      () => HttpHandlerService(serverAddress!));
  getIt.registerLazySingleton<ChatService>(() => ChatService());
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<ThemeService>(() => ThemeService());
  getIt.registerLazySingleton<LanguageService>(() => LanguageService());
  getIt.registerLazySingleton<RoomService>(() => RoomService());
  getIt.registerLazySingleton<GameService>(() => GameService());
}

Future<void> main() async {
  await setup();
  runApp(const PolyScrabble());
}

class PolyScrabble extends StatefulWidget {
  const PolyScrabble({super.key});

  @override
  State<PolyScrabble> createState() => _PolyScrabbleState();
}

class _PolyScrabbleState extends State<PolyScrabble> {
  final _themeService = GetIt.I.get<ThemeService>();
  final _languageService = GetIt.I.get<LanguageService>();
  StreamSubscription? themeSub;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    themeSub ??= _themeService.notifyThemeChange.stream.listen((event) {
      setState(() {});
    });

    return MaterialApp(
      title: 'PolyScrabble 110',
      theme: _themeService.getTheme(),
      // Static mode, will be light theme in dynamic
      darkTheme: _themeService.getDarkMode(),
      // Dark mode will be used only in dynamic mode
      themeMode: _themeService.isDynamic ? ThemeMode.system : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(title: 'PolyScrabble 101 - Prototype'),
      localizationsDelegates: [
        FlutterI18nDelegate(
          translationLoader: FileTranslationLoader(
              forcedLocale: _languageService.currentLocale),
          missingTranslationHandler: (key, locale) {
            debugPrint(
                "--- Missing Key: $key, languageCode: ${locale!.languageCode}");
          },
        )
      ],
    );
  }
}
