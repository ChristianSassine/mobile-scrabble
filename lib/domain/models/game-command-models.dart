import 'package:mobile/domain/enums/letter-enum.dart';
import 'package:mobile/domain/models/iuser-model.dart';
import 'package:mobile/domain/models/room-model.dart';

class Coordinate {
  int x;
  int y;

  Coordinate(this.x, this.y);

  Map toJson() => {
    "x": x,
    "y": y
  };
}


class PlaceLetterCommandInfo {
  Coordinate firstCoordinate;
  bool? isHorizontal;
  List<String> letters;

  PlaceLetterCommandInfo(this.firstCoordinate, this.isHorizontal, this.letters);

  Map toJson() => {
    "firstCoordinate": firstCoordinate.toJson(),
    "isHorizontal": isHorizontal,
    "letters": letters,
  };
}

class PlayerInformation{
  RoomPlayer player;
  int score;
  List<Letter> rack;

  PlayerInformation.fromJson(json):
        player = RoomPlayer.fromJson(json['player']),
        score = json['score'],
        rack = json['rack']?.map<Letter>((letter) => Letter.fromCharacter(letter['value'])!)?.toList();
}

class GameInfo {
  List<String> gameboard;
  List<PlayerInformation> players;
  IUser? activePlayer;

  GameInfo.fromJson(json):
  gameboard = json['gameboard']?.map<String>((letter) => letter as String)?.toList(),
  players = json['players'].map<PlayerInformation>(PlayerInformation.fromJson).toList(),
  activePlayer = json['activePlayer'] != null ? IUser.fromJson(json['activePlayer']) : null;
}
