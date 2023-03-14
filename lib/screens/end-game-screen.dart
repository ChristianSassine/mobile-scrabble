import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mobile/screens/menu-screen.dart';


class EndGameScreen extends StatefulWidget {
  const EndGameScreen({super.key, required this.title});

  final String title;

  @override
  State<EndGameScreen> createState() => _EndGameScreenState();
}

class _EndGameScreenState extends State<EndGameScreen> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(FlutterI18n.translate(context, "end_game.game_ended"), style: TextStyle(fontWeight: FontWeight.bold),),
              SizedBox(
                  width: 250,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  MenuScreen(
                                      title: FlutterI18n.translate(context, "menu_screen.screen_name")))),
                          child: Text(FlutterI18n.translate(context, "end_game.return_to_menu")))
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
