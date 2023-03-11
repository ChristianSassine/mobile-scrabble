import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/services/auth-service.dart';
import 'package:mobile/screens/chat-screen.dart';
import 'package:mobile/screens/create-game-screen.dart';
import 'package:mobile/screens/room-selection-screen.dart';
import 'package:mobile/screens/signup-screen.dart';

import 'login-screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key, required this.title});

  final String title;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final authService = GetIt.I.get<AuthService>();
  var loggedIn = false;

  // Subscriptions
  StreamSubscription? subLogin;
  StreamSubscription? subLogout;
  StreamSubscription? subError;

  // SnackBars
  final _loggedInSnackBar = const SnackBar(
    content: Text(
      "Connection réussite!",
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 3),
    backgroundColor: Colors.green,
  );
  final _loggedOutSnackBar = const SnackBar(
    content: Text(
      "Déconnection réussite!",
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 3),
    backgroundColor: Colors.brown,
  );

  @override
  Widget build(BuildContext context) {
    subLogin ??= authService.notifyLogin.stream.listen((event) {
      setState(() {
        loggedIn = authService.isConnected();
      });
      ScaffoldMessenger.of(context).showSnackBar(_loggedInSnackBar);
    });

    subLogout ??= authService.notifyLogout.stream.listen((event) {
      setState(() {
        loggedIn = authService.isConnected();
      });
      ScaffoldMessenger.of(context).showSnackBar(_loggedOutSnackBar);
    });

    subError ??= authService.notifyError.stream.listen((event) {
      setState(() {
        loggedIn = authService.isConnected();
      });

      var errorSnackBar = SnackBar(
        content: Text(
          event,
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      );

      ScaffoldMessenger.of(context).showSnackBar(errorSnackBar);
    });

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/scrabble_logo.png", width: 500),
              const SizedBox(height: 50),
              Card(
                  child: Padding(
                      padding: const EdgeInsets.only(
                          left: 30.0, right: 30, bottom: 15, top: 15),
                      child: Column(children: [
                        Text(
                            authService.isConnected()
                                ? "Bienvenue ${authService.username!}"
                                : "Aucune connection",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            onPressed: loggedIn
                                ? null
                                : () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginScreen(
                                                    title:
                                                        "Page de connection")));
                                  },
                            child: const Text("Se connecter")),
                        const SizedBox(height: 5),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: !loggedIn
                                ? null
                                : () {
                                    authService.disconnect();
                                  },
                            child: const Text("Se deconnecter")),
                        const SizedBox(height: 5),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue),
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SigninScreen(
                                        title: "Création de compte"))),
                            child: const Text("Créer un compte")),
                      ]))),
              const SizedBox(height: 30),
              SizedBox(
                  width: 250,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                          onPressed: !loggedIn
                              ? null
                              : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const GameCreationScreen(
                                              title: "Création d'une partie"))),
                          child: const Text("Créer une partie")),
                      ElevatedButton(
                          onPressed: !loggedIn
                              ? null
                              : () => {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const RoomSelectionScreen(
                                                  "Prototype: Salle de clavarage")),
                                    )
                                  },
                          child: const Text("Rejoindre une partie")),

                      // TO BE REMOVED
                      ElevatedButton(
                          onPressed: !loggedIn
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const ChatScreen(
                                            title:
                                                "Prototype: Salle de clavarage")),
                                  );
                                },
                          child:
                              const Text("Rejoindre une salle de clavardage"))
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (subError != null) {
      subError!.cancel();
    }

    if (subLogin != null) {
      subLogin!.cancel();
    }

    if (subLogout != null) {
      subLogout!.cancel();
    }
    super.dispose();
  }
}
