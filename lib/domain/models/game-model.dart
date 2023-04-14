import 'dart:math';

import 'package:mobile/domain/models/board-models.dart';
import 'package:mobile/domain/models/easel-model.dart';
import 'package:mobile/domain/models/game-command-models.dart';
import 'package:mobile/domain/models/user-auth-models.dart';
import 'package:mobile/domain/models/room-model.dart';

class Game {
  final Board gameboard = Board(15);
  List<GamePlayer> players;
  late GamePlayer currentPlayer;
  GamePlayer? activePlayer;
  final int timerLength;
  int turnTimer = 0;
  int reserveLetterCount = 0;

  Game(GameRoom room, IUser currentUser)
      : players = room.players
            .map<GamePlayer>((roomPlayer) => GamePlayer(Easel(7), 0, roomPlayer))
            .toList(), timerLength = room.timer {
    currentPlayer =
        players.firstWhere((player) => player.player.user.username == currentUser.username);
  }

  void nextTurn(GameInfo gameInfo) {
    turnTimer = 0;
    update(gameInfo);
  }

  void update(GameInfo gameInfo) {
    gameboard.updateFromString(gameInfo.gameboard);
    if (gameInfo.players.isEmpty) return;

    setActivePlayer(gameInfo.activePlayer);

    List<PlayerInformation> unknownPlayer = [];
    List<GamePlayer> notVisitedPlayers = players.toList();
    gameInfo.players.forEach((playerInfo) {
      int playerIndex = notVisitedPlayers
          .indexWhere((element) => element.player.user.id == playerInfo.player.user.id);
      if (playerIndex >= 0) {
        notVisitedPlayers[playerIndex].update(playerInfo);
        notVisitedPlayers.removeAt(playerIndex);
      } else {
        unknownPlayer.add(playerInfo);
      }
    });

    // If room player changed
    while (unknownPlayer.isNotEmpty) {
      if(notVisitedPlayers.isNotEmpty) {
        notVisitedPlayers[0].update(unknownPlayer[0]);
        notVisitedPlayers.removeAt(0);
      }else{
        players.add(unknownPlayer[0].createGamePlayer());
      }
      unknownPlayer.removeAt(0);
    }

    if(notVisitedPlayers.isNotEmpty){
      players.removeWhere((element) => notVisitedPlayers.contains(element));
    }

  }

  void setActivePlayer(IUser? newActivePlayer) {
    if (newActivePlayer == null) {
      activePlayer = null;
      return;
    }

    int activePlayerIndex =
        players.indexWhere((player) => player.player.user.username == newActivePlayer.username);
    if (activePlayerIndex >= 0) {
      activePlayer = players[activePlayerIndex];
    }
  }

  bool isCurrentPlayersTurn(){
    return activePlayer != null && currentPlayer.player.user.id == activePlayer!.player.user.id;
  }

  double getTurnProcess(){
    return min(turnTimer / timerLength, 1);
  }
}

class GamePlayer {
  Easel easel;
  int score;
  RoomPlayer player;

  GamePlayer(this.easel, this.score, this.player);

  void update(PlayerInformation playerInfo) {
    easel.updateFromRack(playerInfo.rack);
    score = playerInfo.score;
    player.playerType = playerInfo.player.playerType;
  }
}
