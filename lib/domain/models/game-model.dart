
import 'package:mobile/domain/models/board-models.dart';
import 'package:mobile/domain/models/easel-model.dart';
import 'package:mobile/domain/models/game-command-models.dart';
import 'package:mobile/domain/models/iuser-model.dart';
import 'package:mobile/domain/models/room-model.dart';

class Game {
  final Board gameboard = Board(15);
  final Easel easel = Easel(7);
  List<RoomPlayer> players;
  IUser currentPlayer;
  RoomPlayer? activePlayer;
  int turnTimer = 0;

  Game(GameRoom room, this.currentPlayer): players = room.players;

  void nextTurn(GameInfo gameInfo) {
    turnTimer = 0;
    if (gameInfo.activePlayer != null) {
      activePlayer =
          players.firstWhere((player) => player.user.username == gameInfo.activePlayer!.username);
    }
  }

  void update(GameInfo gameInfo){
    gameboard.updateFromString(gameInfo.gameboard);
    if (gameInfo.players.isEmpty) return;
    easel.updateFromRack(gameInfo.players
        .firstWhere((PlayerInformation player) =>
    player.player.user.username == currentPlayer.username)
        .rack);
    if (gameInfo.activePlayer != null) {
      activePlayer = players.firstWhere((player) => player.user.username == gameInfo.activePlayer!.username);
    }
  }

}
