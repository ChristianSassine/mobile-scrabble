import 'package:flutter/foundation.dart';
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
    debugPrint("[GAME SERVICE] Place letter to the board: board[$x][$y] = $letter");
    if (!_isLetterPlacementValid(x, y, letter)) {
      if (draggedLetter != null) cancelDragLetterFromEasel(); // Wrong move
      return;
    }

    gameboard.placeLetter(x, y, letter);
    _pendingLetters.add(LetterPlacement(x, y, letter));
    _pendingLetters.sort((a, b) => a.x.compareTo(b.x) + a.y.compareTo(b.y));

    //TODO: CALL SERVER IMPLEMENTATION FOR SYNC
  }

  bool _isLetterPlacementValid(int x, int y, Letter letter) {
    if (!gameboard.isSlotEmpty(x, y)) return false;

    if (_pendingLetters.isEmpty) {
      return _isAdjacentToOtherLetters(x, y) || gameboard.isEmpty();
    }

    LetterPlacement lastPlacement = _pendingLetters.last;
    bool sameColumn = lastPlacement.x == x, sameRow = lastPlacement.y == y;
    if (!(sameColumn || sameRow)) return false;

    if (sameColumn) {
      if (_pendingLetters.any((placement) => placement.x != x)) {
        return false; // Not all on the same column
      }
      for (int checkY = lastPlacement.y; (y - checkY).abs() > 0; checkY += y.compareTo(lastPlacement.y)) {
        if (gameboard.isSlotEmpty(x, checkY)) {
          return false; // Empty slot between last placement
        }
      }
    } else {
      if (_pendingLetters.any((placement) => placement.y != y)) {
        return false; // Not all on the same row
      }
      for (int checkX = lastPlacement.x;
          (x - checkX).abs() > 0;
          checkX += x.compareTo(lastPlacement.x)) {
        if (gameboard.isSlotEmpty(checkX, y)) {
          return false; // Empty slot between last placement
        }
      }
    }
    return true;
  }

  bool _isAdjacentToOtherLetters(int x, int y) {
    if (!gameboard.isSlotEmpty(x, y)) return false;

    Letter? left = gameboard.getSlot(x - 1, y),
        right = gameboard.getSlot(x + 1, y),
        top = gameboard.getSlot(x, y - 1),
        down = gameboard.getSlot(x, y + 1);

    return left != null || right != null || top != null || down != null;
  }

  /// @return the removed letter
  Letter? removeLetterFromBoard(int x, int y) {
    //TODO: CALL SERVER IMPLEMENTATION FOR SYNC

    if (isPlacedLetterRemovalValid(x, y)) {
      _pendingLetters.removeWhere((placement) => placement.x == x && placement.y == y);

      debugPrint(
          "[GAME SERVICE] Remove letter from the board: board[$x][$y] = ${gameboard.getSlot(x, y)}");

      return gameboard.removeLetter(x, y);
    } else {
      return null;
    }
  }

  bool isPlacedLetterRemovalValid(int x, int y) {
    int pendingLetterIndex = _pendingLetters.indexWhere((letter) => letter.x == x && letter.y == y);

    if (pendingLetterIndex < 0) {
      return false; //Letter not in pending letters
    }

    // These are the extremities of the letter placement since the list is sorted
    return pendingLetterIndex == 0 || pendingLetterIndex == _pendingLetters.length - 1;
  }

  bool isPendingLetter(int x, int y) {
    return _pendingLetters.indexWhere((placement) => placement.x == x && placement.y == y) >= 0;
  }

  void addLetterInEasel(Letter letter) {
    debugPrint(
        "[GAME SERVICE] Add letter to the end of easel: easel[${easel.getLetterList().length}] = $letter");
    easel.addLetter(letter);

    //TODO: CALL SERVER IMPLEMENTATION FOR SYNC
  }

  void addLetterInEaselAt(int index, Letter letter) {
    easel.addLetterAt(index, letter);
    debugPrint("[GAME SERVICE] Add letter to easel[$index] = $letter");

    //TODO: CALL SERVER IMPLEMENTATION FOR SYNC
  }

  /// @return null if index is out of bound
  Letter? removeLetterFromEaselAt(int index) {
    Letter? removedLetter = easel.removeLetterAt(index);
    debugPrint("[GAME SERVICE] Remove letter from easel[$index] - $removedLetter");

    //TODO: CALL SERVER IMPLEMENTATION FOR SYNC

    return removedLetter;
  }

  Letter? dragLetterFromEasel(int index) {
    debugPrint("[GAME SERVICE] Start drag from easel");
    draggedLetter = removeLetterFromEaselAt(index);
    return draggedLetter;
  }

  void cancelDragLetterFromEasel() {
    debugPrint("[GAME SERVICE] Cancel drag");
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
