import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/enums/socket-events-enum.dart';
import 'package:mobile/domain/models/game-command-models.dart';
import 'package:mobile/domain/models/game-model.dart';
import 'package:mobile/domain/models/letter-synchronisation-model.dart';
import 'package:mobile/domain/models/room-model.dart';
import 'package:mobile/domain/services/room-service.dart';
import 'package:mobile/domain/services/user-service.dart';
import 'package:mobile/screens/end-game-screen.dart';
import 'package:rxdart/rxdart.dart';
import '../enums/letter-enum.dart';
import 'package:socket_io_client/socket_io_client.dart';

class LetterPlacement {
  final int x, y;
  final Letter letter;
  final bool isStar;

  const LetterPlacement(this.x, this.y, this.letter, this.isStar);
}

class GameService {
  final _socket = GetIt.I.get<Socket>();
  final _userService = GetIt.I.get<UserService>();
  final _roomService = GetIt.I.get<RoomService>();

  Subject<bool> notifyGameInfoChange = PublishSubject();
  Subject<String> notifyGameError = PublishSubject();

  GameRoom? _gameRoom;
  Letter? draggedLetter;
  List<LetterPlacement> pendingLetters = [];

  GamePlayer? observerView;

  Game? game;

  GameService() {
    setupSocketListeners();
  }

  void startGame(GameInfo initialGameInfo) async {
    _gameRoom = GetIt.I.get<RoomService>().currentRoom!;
    game = Game(_gameRoom!, _userService.user!);

    _publicViewUpdate(initialGameInfo);

    if (game!.currentPlayer.player.playerType == PlayerType.Observer) {
      observerView = game!.players.firstWhere((element) => element.player.isCreator == true);
    }

    while (game != null) {
      game!.turnTimer += 1;
      notifyGameInfoChange.add(false);
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  void setupSocketListeners() {
    _socket.on(RoomSocketEvent.PublicViewUpdate.event,
        (data) => _publicViewUpdate(GameInfo.fromJson(data)));

    _socket.on(GameSocketEvent.NextTurn.event, (data) => _nextTurn(GameInfo.fromJson(data)));
    _socket.on(GameSocketEvent.GameEnded.event, (_) => _endGame());
    _socket.on(GameSocketEvent.LetterReserveUpdated.event, (letters) {
      game!.reserveLetterCount =
          letters.map((letter) => letter['quantity']).toList().reduce((a, b) => a + b);
    });
    _socket.on(GameSocketEvent.PlacementSuccess.event, (_) => _successfulWordPlacement());
    _socket.on(GameSocketEvent.PlacementFailure.event, (error) => _invalidWordPlacement(error));
    _socket.on(GameSocketEvent.CannotReplaceBot.event, (_) => _cannotReplaceBot());
    _socket.on(
        GameSocketEvent.DragEvent.event, (dragInfos) => _syncDrag(DragInfos.fromJson(dragInfos)));
    _socket.on(GameSocketEvent.LetterTaken.event,
        (tile) => _syncLetterTaken(SimpleLetterInfos.fromJson(tile)));
    _socket.on(GameSocketEvent.LetterPlaced.event,
        (tile) => _syncLetterPlaced(SimpleLetterInfos.fromJson(tile)));
  }

  void _publicViewUpdate(GameInfo gameInfo) {
    if (game == null) return;

    game!.update(gameInfo);
    pendingLetters.clear();

    if (observerView != null && game!.currentPlayer.player.playerType == PlayerType.User) {
      observerView = null;
    }

    notifyGameInfoChange.add(true);
  }

  void _nextTurn(GameInfo gameInfo) {
    if (game == null) return;
    game!.nextTurn(gameInfo);
    notifyGameInfoChange.add(true);
  }

  void _endGame() {
    Navigator.pushReplacement(GetIt.I.get<GlobalKey<NavigatorState>>().currentContext!,
        MaterialPageRoute(builder: (context) => const EndGameScreen()));

    game = null;
  }

  void placeLetterOnBoard(int x, int y, Letter letter, bool isStarLetter) {
    if (!game!.isCurrentPlayersTurn()) return;

    debugPrint("[GAME SERVICE] Place letter to the board: board[$x][$y] = $letter");
    if (!_isLetterPlacementValid(x, y, letter)) {
      if (draggedLetter != null) cancelDragLetter(); // Wrong move
      return;
    }

    game!.gameboard.placeLetter(x, y, letter);
    LetterPlacement placement = LetterPlacement(x, y, letter, isStarLetter);
    pendingLetters.add(placement);
    pendingLetters.sort((a, b) => a.x.compareTo(b.x) + a.y.compareTo(b.y));

    _socket.emit(
        GameSocketEvent.LetterPlaced.event,
        SimpleLetterInfos(_roomService.currentRoom!.id, _socket.id!, letter.character,
            x + y * game!.gameboard.size));
  }

  bool _isLetterPlacementValid(int x, int y, Letter letter) {
    if (!game!.gameboard.isSlotEmpty(x, y)) return false;

    if (pendingLetters.isEmpty) {
      return _isAdjacentToOtherLetters(x, y) || game!.gameboard.isEmpty();
    }

    LetterPlacement lastPlacement = pendingLetters.last;
    bool sameColumn = lastPlacement.x == x, sameRow = lastPlacement.y == y;
    if (!(sameColumn || sameRow)) return false;

    if (sameColumn) {
      if (pendingLetters.any((placement) => placement.x != x)) {
        return false; // Not all on the same column
      }
      for (int checkY = lastPlacement.y;
          (y - checkY).abs() > 0;
          checkY += y.compareTo(lastPlacement.y)) {
        if (game!.gameboard.isSlotEmpty(x, checkY)) {
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
        if (game!.gameboard.isSlotEmpty(checkX, y)) {
          return false; // Empty slot between last placement
        }
      }
    }
    return true;
  }

  bool _isAdjacentToOtherLetters(int x, int y) {
    if (!game!.gameboard.isSlotEmpty(x, y)) return false;

    Letter? left = game!.gameboard.getSlot(x - 1, y),
        right = game!.gameboard.getSlot(x + 1, y),
        top = game!.gameboard.getSlot(x, y - 1),
        down = game!.gameboard.getSlot(x, y + 1);

    return left != null || right != null || top != null || down != null;
  }

  /// @return the removed letter
  Letter? removeLetterFromBoard(int x, int y) {
    //TODO: CALL SERVER IMPLEMENTATION FOR SYNC

    if (isPlacedLetterRemovalValid(x, y)) {
      LetterPlacement placement =
          pendingLetters.firstWhere((placement) => placement.x == x && placement.y == y);
      pendingLetters.remove(placement);

      debugPrint(
          "[GAME SERVICE] Remove letter from the board: board[$x][$y] = ${game!.gameboard.getSlot(x, y)}");

      Letter? removedLetter = game!.gameboard.removeLetter(x, y);

      _socket.emit(
          GameSocketEvent.LetterTaken.event,
          SimpleLetterInfos(_roomService.currentRoom!.id, _socket.id!, removedLetter!.character,
              x + y * game!.gameboard.size));

      if (placement.isStar) {
        removedLetter = Letter.STAR;
      }

      return removedLetter;
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
        "[GAME SERVICE] Add letter to the end of easel: easel[${game!.currentPlayer.easel.getLetterList().length}] = $letter");
    game!.currentPlayer.easel.addLetter(letter);

    //TODO: CALL SERVER IMPLEMENTATION FOR SYNC
  }

  void addLetterInEaselAt(int index, Letter letter) {
    game!.currentPlayer.easel.addLetterAt(index, letter);
    debugPrint("[GAME SERVICE] Add letter to easel[$index] = $letter");

    //TODO: CALL SERVER IMPLEMENTATION FOR SYNC
  }

  /// @return null if index is out of bound
  Letter? removeLetterFromEaselAt(int index) {
    Letter? removedLetter = game!.currentPlayer.easel.removeLetterAt(index);
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
    Letter? removedLetter = game!.currentPlayer.easel.removeLetter(letter);

    //TODO: CALL SERVER IMPLEMENTATION FOR SYNC

    return removedLetter;
  }

  void confirmWordPlacement() {
    Coordinate firstCoordonate = Coordinate(pendingLetters[0].x, pendingLetters[0].y);
    bool? isHorizontal =
        pendingLetters.length > 1 ? pendingLetters[0].y == pendingLetters[1].y : null;
    List<String> letters = List.generate(
        pendingLetters.length,
        (index) => pendingLetters[index].isStar
            ? pendingLetters[index].letter.character.toLowerCase()
            : pendingLetters[index].letter.character);

    debugPrint("[Game Service] Confirm word placement ${letters.toString()}");
    _socket.emit(GameSocketEvent.PlaceWordCommand.event,
        PlaceWordCommandInfo(firstCoordonate, isHorizontal, letters));

    game!.gameboard.notifyBoardChanged.add(true);
  }

  void _successfulWordPlacement() {
    if (pendingLetters.isEmpty) return;

    debugPrint("[Game Service] Placement success");
    pendingLetters.clear();
    game!.gameboard.notifyBoardChanged.add(true);
  }

  void _invalidWordPlacement(error) {
    debugPrint("[Game Service] Invalid word placement");

    var gameboardMatrix = game!.gameboard.getBoardMatrix();

    for (var placement in pendingLetters) {
      gameboardMatrix[placement.x][placement.y] = null;
      game!.currentPlayer.easel.addLetter(placement.letter);
    }

    pendingLetters.clear();
    game!.gameboard.notifyBoardChanged.add(true);

    if (error is! String) {
      error = error['stringFormat'];
    }

    notifyGameError.add(error);
  }

  void skipTurn() {
    _socket.emit(GameSocketEvent.Skip.event);
  }

  void abandonGame() {
    _socket.emit(GameSocketEvent.AbandonGame.event);

    game = null;
  }

  void quitGame() {
    _socket.emit(GameSocketEvent.QuitGame.event);
  }

  void exchangeLetters(List<Letter> lettersToExchange) {
    List<String> sLetters = lettersToExchange.map((letter) => letter.character).toList();
    _socket.emit(GameSocketEvent.Exchange.event, [sLetters]);
  }

  switchToPlayerView(GamePlayer player) {
    if (player.player.playerType == PlayerType.Bot) {
      _socket.emit(GameSocketEvent.JoinAsObserver.event, player.player.user.id);
    } else {
      observerView = player;
    }
  }

  _cannotReplaceBot() {}

  _syncDrag(dragInfos) {}

  _syncLetterPlaced(SimpleLetterInfos simpleLetterInfos) {
    if (simpleLetterInfos.socketId != _socket.id) {
      int x = simpleLetterInfos.coord % game!.gameboard.size;
      int y = simpleLetterInfos.coord ~/ game!.gameboard.size;
      Letter? letter = Letter.fromCharacter(simpleLetterInfos.letter);

      if(letter == null){
        debugPrint("Sync error: ${simpleLetterInfos.letter} is not a valid letter");
        return;
      }

      pendingLetters.add(LetterPlacement(x, y, letter, false));
      game!.gameboard.placeLetter(x, y, letter);

      debugPrint(
          "New letter placed: ${pendingLetters.map((placement) => "(${placement.x}, ${placement.y}): ${placement.letter}").toList().toString()}");
    }
  }

  _syncLetterTaken(SimpleLetterInfos simpleLetterInfos) {
    if (simpleLetterInfos.socketId != _socket.id) {
      int x = simpleLetterInfos.coord % game!.gameboard.size;
      int y = simpleLetterInfos.coord ~/ game!.gameboard.size;
      int index = pendingLetters.indexWhere((element) =>
          element.x == x &&
          element.y == y);
      if (index >= 0) {
        pendingLetters.removeAt(index);
        game!.gameboard.removeLetter(x, y);
        debugPrint(
            "New letter taken: ${pendingLetters.map((placement) => "(${placement.x}, ${placement.y}): ${placement.letter}").toList().toString()}");
        game!.gameboard.notifyBoardChanged.add(true);
      } else {
        debugPrint("Received sync letter taken that is not in pending letters...");
      }
    }
  }
}
