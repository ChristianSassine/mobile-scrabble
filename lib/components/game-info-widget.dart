import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
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
    return Card(
      color: Colors.green[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 25),
          PlayerInfo(),
          const SizedBox(height: 25),
          GameInfo(
            draggableKey: draggableKey,
          ),
        ],
      ),
    );
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

  _GameInfoState() {
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
                          LetterReserve(draggableKey: widget.draggableKey),
                          SizedBox(
                            width: 125,
                            child: Row(children: [
                              const Icon(Icons.timer),
                              Text(
                                  " ${_gameService.game!.timerLength - _gameService.game!.turnTimer} ${FlutterI18n.translate(context, "game.second")}s")
                            ]),
                          ),
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
                onPressed: _gameService.pendingLetters.isEmpty
                    ? null
                    : () => {_gameService.confirmWordPlacement()},
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(FlutterI18n.translate(context, "game.place")),
                )),
            const SizedBox(width: 50),
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: _gameService.game!.isCurrentPlayersTurn()
                    ? () => {_gameService.skipTurn()}
                    : null,
                child: const Padding(
                  padding: EdgeInsets.all(17.0),
                  child: Icon(Icons.skip_next_rounded),
                ))
          ],
        )
      ],
    );
  }
}

class PlayerInfo extends StatefulWidget {
  const PlayerInfo({Key? key}) : super(key: key);

  @override
  State<PlayerInfo> createState() => _PlayerInfoState();
}

class _PlayerInfoState extends State<PlayerInfo> {
  final _gameService = GetIt.I.get<GameService>();
  final _avatarService = GetIt.I.get<AvatarService>();

  late StreamSubscription _gameInfoUpdate;

  _PlayerInfoState() {
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

    final ColorScheme colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: 300,
      child: Column(
        children: [
          for (GamePlayer player in _gameService.game!.players) ...[
            if (player.player.playerType != PlayerType.Observer)
              Card(
                  color: Colors.lightGreen[100],
                  elevation: 10,
                  child: SizedBox(
                    width: 260,
                    child: Stack(children: [
                      if (_gameService.game!.activePlayer?.player.user.id == player.player.user.id)
                        Card(
                          color: Colors.blue[200]?.withOpacity(0.8),
                          child: SizedBox(
                            width: 260 * (1 - _gameService.game!.getTurnProcess()),
                            height: 65,
                          ),
                        ),
                      ListTile(
                        leading: CircleAvatar(
                            backgroundImage: (player.player.playerType == PlayerType.Bot)
                                ? NetworkImage(_avatarService.botImageUrl)
                                : player.player.user.profilePicture?.key != null
                                    ? NetworkImage(player.player.user.profilePicture!.key!)
                                    : null,
                            child: player.player.user.profilePicture?.key != null
                                ? null
                                : const Icon(CupertinoIcons.profile_circled)),
                        title: Row(
                          children: [
                            Text(player.player.user.username),
                            const SizedBox(
                              width: 5,
                            ),
                            if (player.player.isCreator == true)
                              const Image(image: AssetImage("assets/images/crown.png"), width: 14),
                          ],
                        ),
                        subtitle: Text("Score: ${player.score}"),
                        trailing: Visibility(
                            visible: _gameService.game!.currentPlayer.player.playerType ==
                                PlayerType.Observer,
                            child: RawMaterialButton(
                              onPressed:
                                  player.player.user.id == _gameService.observerView?.player.user.id
                                      ? null
                                      : () => _gameService.switchToPlayerView(player),
                              elevation: 0,
                              fillColor:
                                  player.player.user.id == _gameService.observerView?.player.user.id
                                      ? Colors.grey.withOpacity(0.5)
                                      : Colors.transparent,
                              shape: const CircleBorder(),
                              constraints: BoxConstraints.tight(const Size.fromRadius(20)),
                              child: Icon(
                                  player.player.playerType == PlayerType.User
                                      ? Icons.visibility
                                      : Icons.play_arrow,
                                  color: Colors.black),
                            )),
                      ),
                    ]),
                  )),
          ]
        ],
      ),
    );
  }
}
