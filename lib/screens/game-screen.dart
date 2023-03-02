import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/services/auth-service.dart';
import 'package:mobile/screens/chat-screen.dart';
import 'package:mobile/screens/create-game-screen.dart';
import 'package:mobile/screens/end-game-screen.dart';
import 'package:mobile/screens/room-selection-screen.dart';
import 'package:mobile/screens/signin-screen.dart';

import 'login-screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.title});

  final String title;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {

  _abandonGame(){
    // TODO: Prompt user confirmation

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const EndGameScreen(title: "Fin de la partie")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: _abandonGame,
            child: const Icon(Icons.flag)
          )
        ],
      ),
      body: Center(child: Text("This is the game screen...")),
    );
  }
}
