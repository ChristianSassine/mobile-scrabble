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
  int turnTimer = 0;

  Game(GameRoom room, IUser currentUser)
      : players = room.players
            .map<GamePlayer>((roomPlayer) => GamePlayer(Easel(7), 0, roomPlayer))
            .toList() {
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

    List<GamePlayer> unknownPlayer = [];
    players.forEach((player) {
      int playerIndex = gameInfo.players
          .indexWhere((element) => element.player.user.username == player.player.user.username);
      if (playerIndex >= 0) {
        player.update(gameInfo.players[playerIndex]);
        gameInfo.players.removeAt(playerIndex);
      } else {
        unknownPlayer.add(player);
      }
    });

    // If room player changed
    while (unknownPlayer.isNotEmpty && gameInfo.players.isNotEmpty) {
      unknownPlayer[0].player = gameInfo.players[0].player;
      unknownPlayer[0].update(gameInfo.players[0]);
      unknownPlayer.removeAt(0);
      gameInfo.players.removeAt(0);
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
}

class GamePlayer {
  Easel easel;
  int score;
  RoomPlayer player;

  GamePlayer(this.easel, this.score, this.player);

  void update(PlayerInformation playerInfo) {
    easel.updateFromRack(playerInfo.rack);
    score = playerInfo.score;
  }
}
