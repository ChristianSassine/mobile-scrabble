import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/models/player-models.dart';
import 'package:mobile/domain/services/game-service.dart';
import 'package:mobile/domain/services/room-service.dart';

class GameInfoWidget extends StatelessWidget {
  const GameInfoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [PlayerInfoWidget()],
      ),
    );
  }
}

class PlayerInfoWidget extends StatefulWidget {
  const PlayerInfoWidget({Key? key}) : super(key: key);

  @override
  State<PlayerInfoWidget> createState() => _PlayerInfoWidgetState();
}

class _PlayerInfoWidgetState extends State<PlayerInfoWidget> {
  final _roomService = GetIt.I.get<RoomService>();
  final _gameService = GetIt.I.get<GameService>();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      child: Column(
        children: [
          for (Player player in _roomService.selectedRoom!.playerList) ...[
            Card(
              child: Container(
                  margin: const EdgeInsets.all(5),
                  width: 250,
                  child: ListTile(
                    title: Text(player.name),
                    subtitle: Text("Score: ${player.score}"),
                    trailing: _gameService.activePlayer == player
                        ? CircularProgressIndicator(
                            value: _gameService.turnTimer / GameService.turnLength)
                        : null,
                  )),
            )
          ]
        ],
      ),
    );
  }
}
