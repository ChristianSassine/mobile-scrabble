import 'package:mobile/domain/models/board-models.dart';
import 'package:mobile/domain/models/easel-model.dart';

import '../enums/letter-enum.dart';

class LetterPlacement {
  final int x, y;
  final Letter letter;

  const LetterPlacement(this.x, this.y, this.letter);
}

class GameService {
  final Board gameboard = Board(15);
  final Easel easel = Easel(7);

  Letter? draggedLetter;

  final List<LetterPlacement> _pendingLetters = [];

  GameService() {
    easel.addLetter(Letter.A);
    easel.addLetter(Letter.B);
    easel.addLetter(Letter.C);
    easel.addLetter(Letter.D);
    easel.addLetter(Letter.E);
    easel.addLetter(Letter.F);
    easel.addLetter(Letter.G);
  }

  void placeLetterOnBoard(int x, int y, Letter letter) {
    if (!_isLetterPlacementValid(x, y, letter)) {
      if (draggedLetter != null) cancelDragLetterFromEasel(); // Wrong move
      return;
    }

    gameboard.placeLetter(x, y, letter);
    _pendingLetters.add(LetterPlacement(x, y, letter));

    //TODO: CALL SERVER IMPLEMENTATION FOR SYNC
  }

  bool _isLetterPlacementValid(int x, int y, Letter letter) {
    if (!gameboard.isSlotEmpty(x, y)) return false;

    bool placementOrientationValid = _isPlacementOrientationValid(x, y);

    if (!placementOrientationValid) {
      //If not valid, letter is not connected to any letter. The only valid move is the starting move
      return x == gameboard.size ~/ 2 && y == gameboard.size ~/ 2;
    }

    bool valid = true;
    if(_pendingLetters.length > 1) {
      bool xLock = _pendingLetters[0].x == _pendingLetters[1].x, yLock = _pendingLetters[0].y == _pendingLetters[1].y;
      _pendingLetters.forEach((letter) {
        // if (!xLock && !yLock) {
        //   // For first iteration
        //   xLock = x == letter.x;
        //   yLock = y == letter.y;
        //   valid = xLock ^ yLock;
        // } else {
          valid &=
              (xLock ? x == letter.x : true) && (yLock ? y == letter.y : true);
        // }
      });
    }

    return placementOrientationValid && valid;
  }

  bool _isPlacementOrientationValid(int x, int y) {
    if (!gameboard.isSlotEmpty(x, y)) return false;

    Letter? left = gameboard.getSlot(x - 1, y),
        right = gameboard.getSlot(x + 1, y),
        top = gameboard.getSlot(x, y - 1),
        down = gameboard.getSlot(x, y + 1);

    bool leftRightPlacement = (left != null && left != Letter.INVALID) ||
        (right != null && right != Letter.INVALID);

    bool topDownPlacement = (top != null && top != Letter.INVALID) ||
        (down != null && down != Letter.INVALID);

    return leftRightPlacement ^ topDownPlacement;
  }

  /// @return the removed letter
  Letter? removeLetterFromBoard(int x, int y) {
    int pendingLetterIndex =
        _pendingLetters.indexWhere((letter) => letter.x == x && letter.y == y);
    if (pendingLetterIndex < 0) {
      return null; //Letter not in pending letters
    }
    _pendingLetters.removeAt(pendingLetterIndex);

    return gameboard.removeLetter(x, y);

    //TODO: CALL SERVER IMPLEMENTATION FOR SYNC
  }

  void addLetterInEasel(Letter letter) {
    easel.addLetter(letter);

    //TODO: CALL SERVER IMPLEMENTATION FOR SYNC
  }

  void addLetterInEaselAt(int index, Letter letter) {
    easel.addLetterAt(index, letter);

    //TODO: CALL SERVER IMPLEMENTATION FOR SYNC
  }

  /// @return null if index is out of bound
  Letter? removeLetterFromEaselAt(int index) {
    Letter? removedLetter = easel.removeLetterAt(index);

    //TODO: CALL SERVER IMPLEMENTATION FOR SYNC

    return removedLetter;
  }

  Letter? dragLetterFromEasel(int index) {
    draggedLetter = removeLetterFromEaselAt(index);
    return draggedLetter;
  }

  void cancelDragLetterFromEasel() {
    addLetterInEasel(draggedLetter!);
    draggedLetter = null;
  }

  /// Remove the first letter in the easel from left to right
  /// @return null if letter is not in easel
  Letter? removeLetterFromEasel(Letter letter) {
    Letter? removedLetter = easel.removeLetter(letter);

    //TODO: CALL SERVER IMPLEMENTATION FOR SYNC

    return removedLetter;
  }

  void fillEaselWithReserve() {
    //TODO: IMPLEMENT
  }
}
