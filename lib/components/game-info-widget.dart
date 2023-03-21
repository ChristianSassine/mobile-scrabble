import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/models/player-models.dart';
import 'package:mobile/domain/services/game-service.dart';
import 'package:mobile/domain/services/room-service.dart';

class GameInfoBar extends StatelessWidget {
  const GameInfoBar({Key? key}) : super(key: key);

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
          const SizedBox(height: 25),
          Row(
            children: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green[400]),
                  onPressed: () => {},
                  child: const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("Placer"),
                  )),
              SizedBox(width: 50),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: () => {},
                  child: const Padding(
                    padding: EdgeInsets.all(17.0),
                    child: Icon(Icons.skip_next_rounded),
                  ))
            ],
          )
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

  @override
  Widget build(BuildContext context) {
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
        ));
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Column(
        children: [
          for (Player player in _roomService.selectedRoom!.playerList) ...[
            Card(
              color: Colors.lightGreen[100],
              elevation: 10,
              child: SizedBox(
                  width: 260,
                  child: ListTile(
                    title: Text(player.name),
                    subtitle: Text("Score: ${player.score}"),
                    trailing: _gameService.activePlayer == player
                        ? CircularProgressIndicator(
                            value: _gameService.turnTimer / GameService.turnLength,
                            color: Colors.blue,
                          )
                        : null,
                  )),
            )
          ]
        ],
      ),
    );
  }
}
