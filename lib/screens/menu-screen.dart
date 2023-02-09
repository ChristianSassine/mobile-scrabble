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

  final _loggedInSnackBar = SnackBar(
    content: Text(
      "Big bear is here!",
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 3),
  );
  final _loggedOutSnackBar = SnackBar(
    content: Text(
      "Big bear is out!",
      textAlign: TextAlign.center,
    ),
    duration: Duration(seconds: 3),
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
      ScaffoldMessenger.of(context).showSnackBar(_loggedInSnackBar);
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
        duration: Duration(seconds: 3),
      );

      ScaffoldMessenger.of(context).showSnackBar(errorSnackBar);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
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
                        child: TextFormField(
                          readOnly: loggedIn,
                          decoration: InputDecoration(
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

                              },
                        child: Text("Sign in")),
                    const SizedBox(height: 5),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        onPressed: !loggedIn ? null : () {},
                        child: Text("Log out")),
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
                child: Text("Rejoindre une salle de clavardage")),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    // TODO: implement dispose
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
