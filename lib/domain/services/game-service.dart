import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/models/board-models.dart';
import 'package:mobile/domain/models/easel-model.dart';
import 'package:mobile/domain/models/game-command-models.dart';
import 'package:mobile/domain/models/player-models.dart';
import 'package:mobile/domain/models/room-model.dart';
import 'package:mobile/domain/services/room-service.dart';
import 'package:rxdart/rxdart.dart';
import '../enums/letter-enum.dart';
import 'package:socket_io_client/socket_io_client.dart';

class LetterPlacement {
  final int x, y;
  final Letter letter;

  const LetterPlacement(this.x, this.y, this.letter);
}

class GameService {
  final _socket = GetIt.I.get<Socket>();

  Subject<bool> notifyGameInfoChange = PublishSubject();

  final GameRoom _gameRoom = GetIt.I
      .get<RoomService>()
      .currentRoom!;
  bool _gameStarted = false;

  final Board gameboard = Board(15);
  final Easel easel = Easel(7);
  Letter? draggedLetter;

  RoomPlayer? activePlayer;

  static const turnLength = 60;
  int turnTimer = 0;


  List<LetterPlacement> pendingLetters = [];

  bool inGame = false;

  GameService() {
    startGame();
  }

  void startGame() async {
    _gameStarted = true;
    activePlayer = _gameRoom.players[0];
    fillEaselWithReserve();

    while (_gameStarted) {
      turnTimer += 1;

      if (turnTimer >= turnLength) {
        nextTurn();
      }

      notifyGameInfoChange.add(true);
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  void nextTurn() {
    turnTimer = 0;
    int lastActivePlayer = _gameRoom.players.indexOf(activePlayer!);
    activePlayer = _gameRoom.players[(lastActivePlayer + 1) % _gameRoom.players.length];
  }

  void setupSocketListeners() {
    // _socket.on("updateClientView", )
  }

  void placeLetterOnBoard(int x, int y, Letter letter) {
    debugPrint("[GAME SERVICE] Place letter to the board: board[$x][$y] = $letter");
    if (!_isLetterPlacementValid(x, y, letter)) {
      if (draggedLetter != null) cancelDragLetter(); // Wrong move
      return;
    }

    gameboard.placeLetter(x, y, letter);
    pendingLetters.add(LetterPlacement(x, y, letter));
    pendingLetters.sort((a, b) => a.x.compareTo(b.x) + a.y.compareTo(b.y));

    //TODO: CALL SERVER IMPLEMENTATION FOR SYNC
  }

  bool _isLetterPlacementValid(int x, int y, Letter letter) {
    if (!gameboard.isSlotEmpty(x, y)) return false;

    if (pendingLetters.isEmpty) {
      return _isAdjacentToOtherLetters(x, y) || gameboard.isEmpty();
    }

    LetterPlacement lastPlacement = pendingLetters.last;
    bool sameColumn = lastPlacement.x == x,
        sameRow = lastPlacement.y == y;
    if (!(sameColumn || sameRow)) return false;

    if (sameColumn) {
      if (pendingLetters.any((placement) => placement.x != x)) {
        return false; // Not all on the same column
      }
      for (int checkY = lastPlacement.y; (y - checkY).abs() > 0;
      checkY += y.compareTo(lastPlacement.y)) {
        if (gameboard.isSlotEmpty(x, checkY)) {
          return false; // Empty slot between last placement
        }
      }
    } else {
      if (pendingLetters.any((placement) => placement.y != y)) {
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
      pendingLetters.removeWhere((placement) => placement.x == x && placement.y == y);

      debugPrint(
          "[GAME SERVICE] Remove letter from the board: board[$x][$y] = ${gameboard.getSlot(
              x, y)}");

      return gameboard.removeLetter(x, y);
    } else {
      return null;
    }
  }

  bool isPlacedLetterRemovalValid(int x, int y) {
    int pendingLetterIndex = pendingLetters.indexWhere((letter) => letter.x == x && letter.y == y);

    if (pendingLetterIndex < 0) {
      return false; //Letter not in pending letters
    }

    // These are the extremities of the letter placement since the list is sorted
    return pendingLetterIndex == 0 || pendingLetterIndex == pendingLetters.length - 1;
  }

  bool isPendingLetter(int x, int y) {
    return pendingLetters.indexWhere((placement) => placement.x == x && placement.y == y) >= 0;
  }

  void addLetterInEasel(Letter letter) {
    debugPrint(
        "[GAME SERVICE] Add letter to the end of easel: easel[${easel
            .getLetterList()
            .length}] = $letter");
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

  Letter? dragLetterFromBoard(int x, int y) {
    debugPrint("[GAME SERVICE] Start drag from board");
    draggedLetter = removeLetterFromBoard(x, y);
    return draggedLetter;
  }

  void cancelDragLetter() {
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
    // TEMPORARY
    while(easel.getLetterList().length != easel.maxSize){
      easel.addLetter(getRandomLetter());
    }
  }

  void confirmWordPlacement() {
    Coordinate firstCoordonate = Coordinate(pendingLetters[0].x, pendingLetters[0].y);
    bool isHorizontal = pendingLetters[0].y == pendingLetters[1].y;
    List<String> letters = List.generate(
        pendingLetters.length, (index) => pendingLetters[index].letter.name);

    // _socket.emit("playGame", CommandInfo(firstCoordonate, isHorizontal, letters));

    // if(isHorizontal){
    //   for(int x = pendingLetters.first.x; x <= pendingLetters.last.x; ++x){
    //     activePlayer?.score += gameboard.getSlot(x, pendingLetters.first.y)!.points;
    //   }
    // }
    // else{
    //   for(int y = pendingLetters.first.y; y <= pendingLetters.last.y; ++y){
    //     activePlayer?.score += gameboard.getSlot(pendingLetters.first.x, y)!.points;
    //   }
    // }

    pendingLetters = [];
    gameboard.notifyBoardChanged.add(true);
    fillEaselWithReserve();
    nextTurn();
  }

  void skipTurn() {
    _socket.emit("skip");
    nextTurn();
  }

  void abandonGame() {
    _socket.emit("AbandonGame");
  }

  void quitGame() {
    _socket.emit("quitGame");
  }

  // TEMPORARY
  Letter getRandomLetter() {
    Random random = Random();
    int letterIndex = random.nextInt(26);

    List<Letter> allLetters = [
      Letter.A,
      Letter.B,
      Letter.C,
      Letter.D,
      Letter.E,
      Letter.F,
      Letter.G,
      Letter.H,
      Letter.I,
      Letter.J,
      Letter.K,
      Letter.L,
      Letter.M,
      Letter.N,
      Letter.O,
      Letter.P,
      Letter.Q,
      Letter.R,
      Letter.S,
      Letter.T,
      Letter.U,
      Letter.V,
      Letter.W,
      Letter.X,
      Letter.Y,
      Letter.Z
    ];

    return allLetters[letterIndex];
  }

}
