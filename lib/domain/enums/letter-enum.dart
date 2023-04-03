enum Letter {
  A("A",1),
  B("B", 3),
  C("C", 3),
  D("D", 2),
  E("E", 1),
  F("F", 4),
  G("G", 2),
  H("H", 4),
  I("I", 1),
  J("J", 8),
  K("K", 10),
  L("L", 1),
  M("M", 2),
  N("N", 1),
  O("O", 1),
  P("P", 3),
  Q("Q", 8),
  R("R", 1),
  S("S", 1),
  T("T", 1),
  U("U", 1),
  V("V", 4),
  W("W", 10),
  X("X", 10),
  Y("Y", 10),
  Z("Z", 10),
  STAR("*", 0),
  EMPTY("_", 0),
  INVALID("-", 0);

  const Letter(this.character, this.points);

  final String character;
  final int points;

  @override
  String toString() {
    return character;
  }

  static Letter? fromCharacter(String character) {
    for (Letter letter in values) {
      if (letter.character == character) {
        return letter;
      }
    }
    return null;
  }
}
