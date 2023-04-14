import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/components/board-widget.dart';
import 'package:mobile/components/chat-widget.dart';
import 'package:mobile/components/easel-widget.dart';
import 'package:mobile/components/game-info-widget.dart';
import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:mobile/domain/classes/snackbar-factory.dart';
import 'package:mobile/domain/services/game-service.dart';
import 'package:mobile/screens/end-game-screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameService _gameService = GetIt.I.get<GameService>();
  final GlobalKey _draggableKey = GlobalKey();

  late StreamSubscription<String> errorSub;

  _promptAbandonConfirmation(context) async {
    if (await confirm(context,
        textOK: Text(FlutterI18n.translate(context, "form.yes")),
        textCancel: Text(FlutterI18n.translate(context, "form.no")),
        title: Text(FlutterI18n.translate(context, "game.abandon_prompt")),
        content: const SizedBox.shrink())) {
      _gameService.abandonGame();
      await Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const EndGameScreen()));
    }
  }

  @override
  void initState() {
    super.initState();
    errorSub = _gameService.notifyGameError.stream.listen((event) {
      String errorMsg = event.length < 4 || event.substring(0, 4) != "game"
          ? '"$event" ${FlutterI18n.translate(context, "game.invalid_word")}'
          : FlutterI18n.translate(context, event);

      ScaffoldMessenger.of(context).showSnackBar(SnackBarFactory.redSnack(errorMsg));
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
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.green[100],
      body: Center(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GameInfoBar(
            draggableKey: _draggableKey,
          ),
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
          Container(width: 300, child: const SideChatWidget()),
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
          onPressed: () => _promptAbandonConfirmation(context)),
    );
  }
}
