import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/models/game-model.dart';
import 'package:mobile/domain/models/room-model.dart';
import 'package:mobile/domain/services/avatar-service.dart';
import 'package:mobile/domain/services/game-service.dart';

class PlayerInfo extends StatefulWidget {
  const PlayerInfo({Key? key}) : super(key: key);

  @override
  State<PlayerInfo> createState() => _PlayerInfoState();
}

class _PlayerInfoState extends State<PlayerInfo> {
  final _gameService = GetIt.I.get<GameService>();
  final _avatarService = GetIt.I.get<AvatarService>();

  late StreamSubscription _gameInfoUpdate;
  late final StreamSubscription _botUrlSub;

  _PlayerInfoState() {
    _gameInfoUpdate = _gameService.notifyGameInfoChange.stream.listen((event) {
      setState(() {});
    });

    _botUrlSub = _avatarService.notifyBotImageUrl.stream.listen((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _gameInfoUpdate.cancel();
    _botUrlSub.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_gameService.game == null) {
      return const SizedBox();
    }

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
                            backgroundImage: (player.player.playerType == PlayerType.Bot && _avatarService.botImageUrl != null)
                                ? NetworkImage(_avatarService.botImageUrl!)
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
