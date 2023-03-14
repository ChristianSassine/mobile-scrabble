import 'dart:core';

import 'package:mobile/domain/enums/letter-enum.dart';
import 'package:rxdart/rxdart.dart';

// TODO: To be adapted to the server board implementation.
// TEMPORARY IMPLEMENTATION FOR UI
class Board {
  Subject<bool> notifyBoardChanged = PublishSubject();

  final int size;
  final List<List<Letter?>> _boardMatrix;
  final BoardLayout layout;

  Board(this.size)
      : _boardMatrix = List.generate(
            size, (i) => List.filled(size, null, growable: false)),
        layout = BoardLayout(15) {}

  bool isSlotEmpty(int x, int y) {
    return isSlotValid(x, y) && _boardMatrix[x][y] == null;
  }

  bool isSlotValid(int x, int y){
    return (0 <= x && x < size && 0 <= y && y < size);
  }

  Letter? getSlot(int x, int y) {
    return isSlotValid(x, y) ? _boardMatrix[x][y] : Letter.INVALID;
  }

  void placeLetter(int x, int y, Letter letter) {
    if (!isSlotValid(x, y) || !isSlotEmpty(x, y)) {
      return;
    }

    _boardMatrix[x][y] = letter;
    notifyBoardChanged.add(true);
  }

  Letter? removeLetter(int x, int y) {
    if (!isSlotValid(x, y) || isSlotEmpty(x, y)) {
      return null;
    }

    Letter? removedLetter = _boardMatrix[x][y];
    _boardMatrix[x][y] = null;
    notifyBoardChanged.add(true);
    return removedLetter;
  }

  List<List<Letter?>> getBoardMatrix() {
    return _boardMatrix;
  }

// Board.fromJson(json)
//       : boardMatrix = json['board'];

// Board toJson() =>
//     {};
}

class BoardLayout {
  final int size;
  final List<List<Modifier>> layoutMatrix;

  BoardLayout(this.size)
      : layoutMatrix = List.generate(
            size, (i) => List.filled(size, Modifier.NONE, growable: false)) {
    if (size == 15) {
      _generateLayout();
    }
  }

  _generateLayout() {
    // Simple algo to set the default layout (15 x 15), but should work for all sizes
    int halfSize = (size / 2).floor();

    for (int i = 0; i < 4; ++i) {
      bool a = (i & 1) > 0, b = (i & 2) > 0;

      // Double word
      for (int i = 1; i < halfSize - 2; ++i) {
        layoutMatrix[a ? size - i - 1 : i][b ? size - i - 1 : i] =
            Modifier.DOUBLE_WORD;
      }

      // Triple word
      layoutMatrix[a ? size - 1 : 0][b ? size - 1 : 0] =
          Modifier.TRIPLE_WORD; // 4 corners
      layoutMatrix[(a ? 0 : halfSize) + (b ? halfSize : 0)]
              [(a ? 0 : halfSize) + (b ? 0 : halfSize)] =
          Modifier.TRIPLE_WORD; // 4 center side points

      // Double letter
      layoutMatrix[a ? size - 4 : 3][b ? size - 1 : 0] = Modifier.DOUBLE_LETTER;
      layoutMatrix[b ? size - 1 : 0][a ? size - 4 : 3] = Modifier.DOUBLE_LETTER;
      layoutMatrix[a ? halfSize - 1 : halfSize + 1][b ? size - 3 : 2] =
          Modifier.DOUBLE_LETTER;
      layoutMatrix[b ? size - 3 : 2][a ? halfSize - 1 : halfSize + 1] =
          Modifier.DOUBLE_LETTER;
      layoutMatrix[a ? halfSize - 1 : halfSize + 1]
          [b ? halfSize - 1 : halfSize + 1] = Modifier.DOUBLE_LETTER;

      // Triple letter
      layoutMatrix[a ? size - 2 : 1][b ? halfSize - 2 : halfSize + 2] =
          Modifier.TRIPLE_LETTER;
      layoutMatrix[b ? halfSize - 2 : halfSize + 2][a ? size - 2 : 1] =
          Modifier.TRIPLE_LETTER;
      layoutMatrix[a ? halfSize - 2 : halfSize + 2]
          [b ? halfSize - 2 : halfSize + 2] = Modifier.TRIPLE_LETTER;

      layoutMatrix[halfSize][halfSize] = Modifier.START;
    }
  }
}

enum Modifier {
  NONE,
  START,
  DOUBLE_LETTER,
  TRIPLE_LETTER,
  DOUBLE_WORD,
  TRIPLE_WORD
}
