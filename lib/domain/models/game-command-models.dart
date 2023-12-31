import 'package:mobile/domain/enums/letter-enum.dart';
import 'package:mobile/domain/models/easel-model.dart';
import 'package:mobile/domain/models/game-model.dart';
import 'package:mobile/domain/models/user-auth-models.dart';
import 'package:mobile/domain/models/room-model.dart';

class Coordinate {
  int x;
  int y;

  Coordinate(this.x, this.y);

  Map toJson() => {"x": x + 1, "y": y + 1};

  Coordinate.fromJson(coord)
      : x = coord['x'] - 1,
        y = coord['y'] - 1;
}

class PlaceWordCommandInfo {
  Coordinate firstCoordinate;
  bool? isHorizontal;
  List<String> letters;

  PlaceWordCommandInfo(this.firstCoordinate, this.isHorizontal, this.letters);

  Map toJson() => {
        "firstCoordinate": firstCoordinate.toJson(),
        "isHorizontal": isHorizontal,
        "letters": letters,
      };

  PlaceWordCommandInfo.fromJson(commandInfo)
      : firstCoordinate = Coordinate.fromJson(commandInfo['firstCoordinate']),
        isHorizontal = commandInfo['isHorizontal'],
        letters = commandInfo['letters'].map<String>((element) => element as String).toList();
}

class PlayerInformation {
  RoomPlayer player;
  int score;
  List<Letter> rack;

  PlayerInformation.fromJson(json)
      : player = RoomPlayer.fromJson(json['player']),
        score = json['score'],
        rack =
            json['rack']?.map<Letter>((letter) => Letter.fromCharacter(letter['value'])!)?.toList();

  GamePlayer createGamePlayer() {
    GamePlayer gamePlayer = GamePlayer(new Easel(7), score, player);
    gamePlayer.easel.updateFromRack(rack);
    return gamePlayer;
  }
}

class GameInfo {
  List<String> gameboard;
  List<PlayerInformation> players;
  IUser? activePlayer;

  GameInfo.fromJson(json)
      : gameboard = json['gameboard']?.map<String>((letter) => letter as String)?.toList(),
        players = json['players'].map<PlayerInformation>(PlayerInformation.fromJson).toList(),
        activePlayer = json['activePlayer'] != null ? IUser.fromJson(json['activePlayer']) : null;
}
