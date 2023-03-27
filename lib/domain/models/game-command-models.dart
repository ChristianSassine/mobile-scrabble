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

}

class GameInfo {
  List<String> gameboard;
  List<PlayerInfo> players;
  IUser? activePlayer;
}
