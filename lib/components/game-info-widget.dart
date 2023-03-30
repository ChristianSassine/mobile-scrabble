import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/models/player-models.dart';
import 'package:mobile/domain/models/room-model.dart';
import 'package:mobile/domain/services/game-service.dart';
import 'package:mobile/domain/services/room-service.dart';
import 'dart:math' as math;

class GameInfoBar extends StatelessWidget {
  final _gameService = GetIt.I.get<GameService>();

  GameInfoBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 25),
          PlayerInfo(),
          const SizedBox(height: 25),
          GameInfo(),
        ],
      ),
    );
  }
}

class GameInfo extends StatefulWidget {
  const GameInfo({Key? key}) : super(key: key);

  @override
  State<GameInfo> createState() => _GameInfoState();
}

class _GameInfoState extends State<GameInfo> {
  final _gameService = GetIt.I.get<GameService>();

  late StreamSubscription _gameInfoUpdate;

  _GameInfoState(){
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
    return Column(
      children: [
        SizedBox(
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
                          Card(
                              color: Colors.lightGreen[50],
                              margin: const EdgeInsets.all(10),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: const [Text("Réserve"), SizedBox(height: 5), Text("100")],
                                ),
                              )),
                          Row(children: [
                            const Icon(Icons.timer),
                            Text(" ${GameService.turnLength - _gameService.turnTimer} secondes")
                          ]),
                        ],
                      )
                    ],
                  )),
            )),
        const SizedBox(height: 25),
        Row(
          children: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[400]),
                onPressed: _gameService.pendingLetters.isEmpty ? null : () => { _gameService.confirmWordPlacement() },
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text("Placer"),
                )),
            const SizedBox(width: 50),
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () => { _gameService.skipTurn() },
                child: const Padding(
                  padding: EdgeInsets.all(17.0),
                  child: Icon(Icons.skip_next_rounded),
                ))
          ],
        )],
    );
  }
}

class PlayerInfo extends StatefulWidget {
  const PlayerInfo({Key? key}) : super(key: key);

  @override
  State<PlayerInfo> createState() => _PlayerInfoState();
}

class _PlayerInfoState extends State<PlayerInfo> {
  final _roomService = GetIt.I.get<RoomService>();
  final _gameService = GetIt.I.get<GameService>();

  late StreamSubscription _gameInfoUpdate;

  _PlayerInfoState(){
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

    return SizedBox(
      width: 300,
      child: Column(
        children: [
          for (RoomPlayer player in _roomService.currentRoom!.players) ...[
            Card(
              color: Colors.lightGreen[100],
              elevation: 10,
              child: SizedBox(
                  width: 260,
                  child: ListTile(
                    title: Text(player.user.username),
                    subtitle: Text("Score: 0"),
                    trailing: _gameService.activePlayer == player
                        ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),child: CircularProgressIndicator(
                            value: 1 - (_gameService.turnTimer / GameService.turnLength),
                            color: Colors.blue,
                          ))
                        : null,
                  )),
            )
          ]
        ],
      ),
    );
  }
}
