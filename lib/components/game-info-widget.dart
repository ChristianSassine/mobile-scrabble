import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/components/game-actions-widget.dart';
import 'package:mobile/components/player-info-widget.dart';
import 'package:mobile/components/reserve-widget.dart';
import 'package:mobile/domain/models/game-model.dart';
import 'package:mobile/domain/models/room-model.dart';
import 'package:mobile/domain/services/avatar-service.dart';
import 'package:mobile/domain/services/game-service.dart';
import 'dart:math' as math;

class GameInfoBar extends StatelessWidget {
  final GlobalKey draggableKey;

  GameInfoBar({Key? key, required this.draggableKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width >
        MediaQuery.of(context).size.height) {
      return Card(
        color: Colors.green[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            PlayerInfo(),
            const SizedBox(height: 25),
            GameInfo(draggableKey: draggableKey),
            const SizedBox(height: 25),
            GameActions(vertical: false)
          ],
        ),
      );
    } else {
      return Card(
        color: Colors.green[200],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              children: [
                const SizedBox(height: 25),
                PlayerInfo(),
                SizedBox(height: 25),
                GameInfo(draggableKey: draggableKey),
              ],
            ),
            GameActions(vertical: true),
            SizedBox(width: 15)
          ],
        ),
      );
    }
  }
}

class GameInfo extends StatefulWidget {
  final GlobalKey draggableKey;

  const GameInfo({Key? key, required this.draggableKey}) : super(key: key);

  @override
  State<GameInfo> createState() => _GameInfoState();
}

class _GameInfoState extends State<GameInfo> {
  final _gameService = GetIt.I.get<GameService>();

  late StreamSubscription _gameInfoUpdate;

  @override
  initState() {
    super.initState();
    _gameInfoUpdate = _gameService.notifyGameInfoChange.stream.listen((event) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _gameInfoUpdate.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_gameService.game == null) {
      return const SizedBox();
    }

    return SizedBox(
        width: 260,
        child: Card(
          color: Colors.lightGreen[200],
          elevation: 10,
          child: Container(
              margin: EdgeInsets.all(5),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      LetterReserve(draggableKey: widget.draggableKey),
                      SizedBox(
                        width: 125,
                        child: Row(children: [
                          const Icon(Icons.timer),
                          Text(
                              " ${_gameService.game!.timerLength - _gameService.game!.turnTimer} ${FlutterI18n.translate(context, "game.second")}s",
                              style: const TextStyle(color: Colors.black))
                        ]),
                      ),
                    ],
                  )
                ],
              )),
        ));
  }
}
