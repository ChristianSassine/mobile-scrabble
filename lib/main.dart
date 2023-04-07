import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/services/auth-service.dart';
import 'package:mobile/domain/services/avatar-service.dart';
import 'package:mobile/domain/services/chat-service.dart';
import 'package:mobile/domain/services/dictionary-service.dart';
import 'package:mobile/domain/services/game-service.dart';
import 'package:mobile/domain/services/http-handler-service.dart';
import 'package:mobile/domain/services/room-service.dart';
import 'package:mobile/domain/services/theme-service.dart';
import 'package:mobile/domain/services/user-service.dart';
import 'package:mobile/screens/login-screen.dart';
import 'package:socket_io_client/socket_io_client.dart';

Future<void> setup() async {
  final getIt = GetIt.instance;

  String envFile = kDebugMode ? 'development.env' : 'production.env';

  // kDebugMode = APK, so hardcoding it for now
  // envFile = 'production.env';

  await dotenv.load(fileName: envFile);
  var serverAddress = dotenv.env["SERVER_URL"];

  getIt.registerLazySingleton<Socket>(() => io(
      "http://$serverAddress:3000",
      OptionBuilder()
          .setTransports(["websocket"])
          .disableAutoConnect()
          .build()));

  Socket socket = getIt<Socket>();

  socket.onConnect((_) => debugPrint('Socket connection established'));
  socket.onDisconnect((data) => debugPrint('Socket connection lost'));

  getIt.registerLazySingleton<HttpHandlerService>(() => HttpHandlerService(
      "https://$serverAddress:3443",
      httpUrl: "http://$serverAddress:3000"));
  getIt.registerLazySingleton<ChatService>(() => ChatService());
  getIt.registerLazySingleton<AuthService>(() => AuthService());
  getIt.registerLazySingleton<SettingsService>(() => SettingsService());
  getIt.registerLazySingleton<RoomService>(() => RoomService());
  getIt.registerLazySingleton<AvatarService>(() => AvatarService());
  getIt.registerLazySingleton<GameService>(() => GameService());
  getIt.registerLazySingleton<UserService>(() => UserService());
  getIt.registerLazySingleton<DictionaryService>(() => DictionaryService());
  getIt.registerSingleton<GlobalKey<NavigatorState>>(
      GlobalKey<NavigatorState>());
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
  final _settingsService = GetIt.I.get<SettingsService>();
  late final StreamSubscription themeSub;

  @override
  void initState() {
    super.initState();

    themeSub = _settingsService.notifyThemeChange.stream.listen((event) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    themeSub.cancel();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PolyScrabble 110',
      theme: _settingsService.getTheme(),
      // Static mode, will be light theme in dynamic
      darkTheme: _settingsService.getDarkMode(),
      // Dark mode will be used only in dynamic mode
      themeMode: _settingsService.isDynamic ? ThemeMode.system : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(title: 'PolyScrabble 101 - Prototype'),
      localizationsDelegates: [
        FlutterI18nDelegate(
          translationLoader: FileTranslationLoader(
              forcedLocale: _settingsService.currentLocale),
          missingTranslationHandler: (key, locale) {
            debugPrint(
                "--- Missing Key: $key, languageCode: ${locale!.languageCode}");
          },
        )
      ],
      navigatorKey: GetIt.I.get<GlobalKey<NavigatorState>>(),
    );
  }
}
