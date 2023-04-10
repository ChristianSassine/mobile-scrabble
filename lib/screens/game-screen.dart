import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/components/board-widget.dart';
import 'package:mobile/components/easel-widget.dart';
import 'package:mobile/components/game-info-widget.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:mobile/domain/classes/snackbar-factory.dart';
import 'package:mobile/domain/services/game-service.dart';
import 'package:mobile/screens/end-game-screen.dart';
import 'package:rxdart/rxdart.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key,});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameService _gameService = GetIt.I.get<GameService>();
  final GlobalKey _draggableKey = GlobalKey();

  late StreamSubscription<String> errorSub;

  _abandonGame() {
    _gameService.abandonGame();
    Navigator.push(context, MaterialPageRoute(builder: (context) => const EndGameScreen()));
  }

  @override
  void initState() {
    super.initState();
    errorSub = _gameService.notifyGameError.stream.listen((event) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBarFactory.redSnack(
    FlutterI18n.translate(context, event)));
    });
  }

  @override
  void dispose() {
    super.dispose();
    errorSub.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      body: Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GameInfoBar(),
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
          child: EaselWidget(
        dragKey: _draggableKey,
      )),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red,
          child: const Icon(Icons.flag),
          onPressed: () async {
            if (await confirm(context,
                textOK: const Text("Oui"),
                textCancel: const Text("Non"),
                content: const Text("Êtes vous sûr de vouloir abandonner?"))) {
              _abandonGame();
            }
          }),
    );
  }
}
