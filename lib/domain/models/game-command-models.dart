class Coordinate {
  int x;
  int y;

  Coordinate(this.x, this.y);

  Map toJson() => {
    "x": x,
    "y": y
  };
}


class CommandInfo {
  Coordinate firstCoordinate;
  bool? isHorizontal;
  List<String> letters;

  CommandInfo(this.firstCoordinate, this.isHorizontal, this.letters);

  Map toJson() => {
    "firstCoordinate": firstCoordinate.toJson(),
    "isHorizontal": isHorizontal,
    "letters": letters,
  };
}
