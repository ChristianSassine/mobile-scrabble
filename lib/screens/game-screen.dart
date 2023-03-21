import 'package:flutter/material.dart';
import 'package:mobile/components/board-widget.dart';
import 'package:mobile/components/easel-widget.dart';
import 'package:mobile/components/game-info-widget.dart';
import 'package:mobile/domain/models/chat-models.dart';
import 'package:mobile/screens/end-game-screen.dart';

import '../components/chatbox-widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.title});

  final String title;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GlobalKey _draggableKey = GlobalKey();

  _abandonGame() {
    // TODO: Prompt user confirmation

    Navigator.push(context, MaterialPageRoute(builder: (context) => const EndGameScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      body: Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GameInfoWidget(),
          Expanded(
            child: InteractiveViewer(
              panEnabled: false,
              // Set it to false to prevent panning.
              boundaryMargin: EdgeInsets.zero,
              minScale: 1,
              maxScale: 4,
              child: BoardWidget(dragKey: _draggableKey),
            ),
          ),
        ],
      )),
      bottomNavigationBar: BottomAppBar(
          child: Container(
              child: EaselWidget(
        dragKey: _draggableKey,
      ))),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red,
          child: const Icon(Icons.flag),
          onPressed: () => _abandonGame()),
    );
  }
}
