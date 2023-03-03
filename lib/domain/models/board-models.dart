import 'dart:core';

import 'package:rxdart/rxdart.dart';

// TODO: To be adapted to the server board implementation.
// TEMPORARY IMPLEMENTATION FOR UI
class Board {

  Subject<bool> notifyBoardChanged = PublishSubject();

  final int size;
  final List<List<Letter?>> _boardMatrix;

  Board(this.size)
      : _boardMatrix = List.generate(
      size, (i) => List.filled(size, null, growable: false)) {}

  bool isSlotEmpty(int x, int y){
    return _boardMatrix[x][y] == null;
  }

  Letter? getSlot(int x, int y){
    return _boardMatrix[x][y];
  }

  void placeLetter(int x, int y, Letter letter){
    if(!isSlotEmpty(x, y)) {
      return;
    }

    _boardMatrix[x][y] = letter;
    notifyBoardChanged.add(true);
  }

  void removeLetter(int x, int y){
    if(isSlotEmpty(x, y)) {
      return;
    }

    _boardMatrix[x][y] = null;
    notifyBoardChanged.add(true);
  }

  List<List<Letter?>> getBoardMatrix(){
    return _boardMatrix;
  }


  // Board.fromJson(json)
  //       : boardMatrix = json['board'];

  // Board toJson() =>
  //     {};
}

enum Letter {
  A("A"),
  B("B"),
  C("C"),
  D("D"),
  E("E"),
  F("F"),
  G("G"),
  H("H"),
  I("I"),
  J("J"),
  K("K"),
  L("L"),
  M("M"),
  N("N"),
  O("O"),
  P("P"),
  Q("Q"),
  R("R"),
  S("S"),
  T("T"),
  U("U"),
  V("V"),
  W("W"),
  X("X"),
  Y("Y"),
  Z("Z"),
  STAR("*");

  const Letter(this.value);

  final String value;

  @override
  String toString(){
    return value;
  }
}
