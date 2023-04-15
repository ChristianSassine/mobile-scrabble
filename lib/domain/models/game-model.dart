import 'dart:math';

import 'package:get_it/get_it.dart';
import 'package:mobile/domain/models/board-models.dart';
import 'package:mobile/domain/models/easel-model.dart';
import 'package:mobile/domain/models/game-command-models.dart';
import 'package:mobile/domain/models/user-auth-models.dart';
import 'package:mobile/domain/models/room-model.dart';
import 'package:mobile/domain/services/room-service.dart';

class Game {
  final _roomService = GetIt.I.get<RoomService>();

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

  void nextTurn() {
    turnTimer = 0;
  }

  void update(GameInfo gameInfo) {
    gameboard.updateFromString(gameInfo.gameboard);
    if (gameInfo.players.isEmpty) return;

    setActivePlayer(gameInfo.activePlayer);

    players.clear();
    players = gameInfo.players.map((playerInfo) => playerInfo.createGamePlayer()).toList();
    
    _roomService.currentRoom!.players = players.map((player) => player.player).toList();
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
