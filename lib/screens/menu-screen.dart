import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/services/auth-service.dart';
import 'package:mobile/screens/chat-screen.dart';

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

  // Form objects
  final _msgController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/scrabble_logo.png", width: 500),
              const SizedBox(height: 100),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 300,
                        child: Form(
                          key: _formKey,
                          child: TextFormField(
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.trim() == '') {
                                return "Entrez un nom d'utilisateur avant de soumettre";
                              }
                              return null;
                            },
                            controller: _msgController,
                            readOnly: loggedIn,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Ecrivez votre nom d'utilisateur ici",
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          onPressed: loggedIn
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    authService
                                        .connectUser(_msgController.text);
                                  }
                                },
                          child: const Text("Sign in")),
                      const SizedBox(height: 5),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          onPressed: !loggedIn
                              ? null
                              : () {
                                  authService.disconnect();
                                },
                          child: const Text("Log out")),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                  onPressed: !loggedIn
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ChatScreen(
                                    title: "Prototype: Salle de clavarage")),
                          );
                        },
                  child: const Text("Rejoindre une salle de clavardage")),
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
