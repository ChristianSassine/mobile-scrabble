import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/components/settings-widget.dart';
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

  @override
  Widget build(BuildContext context) {
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
                            loggedIn
                                ? "${FlutterI18n.translate(context, "menu_screen.welcome")}"
                                : FlutterI18n.translate(
                                    context, "menu_screen.no_connection"),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            onPressed: false
                                ? null
                                : () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => LoginScreen(
                                                title: FlutterI18n.translate(
                                                    context,
                                                    "menu_screen.login_screen"))));
                                  },
                            child: Text(FlutterI18n.translate(
                                context, "menu_screen.login"))),
                        const SizedBox(height: 5),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: false ? null : () {},
                            child: Text(FlutterI18n.translate(
                                context, "menu_screen.disconnect"))),
                        const SizedBox(height: 5),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue),
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignupScreen(
                                        title: FlutterI18n.translate(context,
                                            "auth.signup.title")))),
                            child: Text(FlutterI18n.translate(
                                context, "menu_screen.sign_up"))),
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
                                      builder: (context) => GameCreationScreen(
                                          title: FlutterI18n.translate(context,
                                              "menu_screen.create_game")))),
                          child: Text(FlutterI18n.translate(
                              context, "menu_screen.create_game"))),
                      ElevatedButton(
                          onPressed: !loggedIn
                              ? null
                              : () => {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              RoomSelectionScreen(
                                                  FlutterI18n.translate(context,
                                                      "menu_screen.join_game"))),
                                    )
                                  },
                          child: Text(FlutterI18n.translate(
                              context, "menu_screen.join_game"))),

                      // TO BE REMOVED
                      ElevatedButton(
                          onPressed: !loggedIn
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                            title: FlutterI18n.translate(
                                                context,
                                                "menu_screen.chat_room"))),
                                  );
                                },
                          child: Text(FlutterI18n.translate(
                              context, "menu_screen.join_chat")))
                    ],
                  )),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.settings),
          onPressed: () {
            showModalBottomSheet(
                context: context,
                builder: (BuildContext context) =>
                    Settings(notifyParent: () => setState(() {})));
          }),
    );
  }
}
