import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/enums/letter-enum.dart';
import 'package:mobile/domain/enums/socket-events-enum.dart';
import 'package:mobile/domain/models/game-command-models.dart';
import 'package:mobile/domain/models/letter-synchronisation-model.dart';
import 'package:mobile/domain/services/game-service.dart';
import 'package:mobile/domain/services/room-service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart';

class GameSyncService {
  final _gameService = GetIt.I.get<GameService>();
  final _roomService = GetIt.I.get<RoomService>();
  final _globalKey = GetIt.I.get<GlobalKey<NavigatorState>>();
  final _socket = GetIt.I.get<Socket>();

  late int _windowWidth, _windowHeight;

  Subject<OpponentDraggedLetter?> notifyNewDraggedLetter = PublishSubject();

  GameSyncService() {
    _windowWidth = MediaQuery.of(_globalKey.currentContext!).size.width.toInt();
    _windowHeight = MediaQuery.of(_globalKey.currentContext!).size.height.toInt();

    _setupSocketListeners();
  }

  _setupSocketListeners() {
    _socket.on(
        GameSocketEvent.DragEvent.event, (dragInfos) => _syncDrag(DragInfos.fromJson(dragInfos)));
    _socket.on(GameSocketEvent.LetterTaken.event,
        (tile) => _syncLetterTaken(SimpleLetterInfos.fromJson(tile)));
    _socket.on(GameSocketEvent.LetterPlaced.event,
        (tile) => _syncLetterPlaced(SimpleLetterInfos.fromJson(tile)));
  }

  _syncDrag(DragInfos dragInfos) {
    if (dragInfos.socketId == _socket.id) return;

    Coordinate draggedLetterCoords = _parseScreenCoordinate(dragInfos);
    Letter? letter = Letter.fromCharacter(dragInfos.letter);
    if (letter == null) return;

    notifyNewDraggedLetter.add(OpponentDraggedLetter(draggedLetterCoords, letter));
  }

  final DESKTOP_TOP_START = 65;
  final DESKTOP_BOARD_SIZE = 600;
  // final DESKTOP_BOARD_MIDDLE_X = 965;
  // final DESKTOP_BOARD_MIDDLE_Y = 545;
  final MOBILE_BOARD_SIZE = 620;
  final MOBILE_BOARD_MIDDLE_X = 630;
  final MOBILE_BOARD_MIDDLE_Y = 260;

  Coordinate _parseScreenCoordinate(DragInfos dragInfos) {
    int windowWidth = dragInfos.window[0], windowHeight = dragInfos.window[1];
    int x = dragInfos.coord[0], y = dragInfos.coord[1];
    // double xRatio = x / windowWidth, yRatio = y / windowHeight;
    // debugPrint("($x, $y) in ($windowWidth, $windowHeight)");
    int xMiddle = windowWidth ~/ 2, yMiddle = (windowHeight - DESKTOP_TOP_START) ~/ 2;
    double normalizedX = (x - xMiddle) / DESKTOP_BOARD_SIZE,
        normalizedY = (y - yMiddle) / DESKTOP_BOARD_SIZE;

    Coordinate coord = Coordinate((MOBILE_BOARD_SIZE * normalizedX + MOBILE_BOARD_MIDDLE_X).toInt(),
        (MOBILE_BOARD_SIZE * normalizedY + MOBILE_BOARD_MIDDLE_Y).toInt());

    debugPrint("($normalizedX, $normalizedY) -> (${coord.x}, ${coord.y})");

    return coord;
  }

  _syncLetterPlaced(SimpleLetterInfos simpleLetterInfos) {
    if (simpleLetterInfos.socketId == _socket.id) return;

    int x = simpleLetterInfos.coord.abs() % _gameService.game!.gameboard.size;
    int y = simpleLetterInfos.coord.abs() ~/ _gameService.game!.gameboard.size;
    Letter? letter = Letter.fromCharacter(simpleLetterInfos.letter);

    if (letter == null) {
      debugPrint("Sync error: ${simpleLetterInfos.letter} is not a valid letter");
      return;
    }

    if (simpleLetterInfos.coord >= 0) {
      _gameService.pendingLetters.add(LetterPlacement(x, y, letter, false));
      _gameService.game!.gameboard.placeLetter(x, y, letter);
      notifyNewDraggedLetter.add(null);
    } else {
      int index =
          _gameService.pendingLetters.indexWhere((element) => element.x == x && element.y == y);
      if (index >= 0) {
        _gameService.pendingLetters.removeAt(index);
        _gameService.game!.gameboard.removeLetter(x, y);
      }
    }

    debugPrint(
        "New letter placed: ${_gameService.pendingLetters.map((placement) => "(${placement.x}, ${placement.y}): ${placement.letter}").toList().toString()}");
  }

  _syncLetterTaken(SimpleLetterInfos simpleLetterInfos) {
    if (simpleLetterInfos.socketId == _socket.id) return;

    int x = simpleLetterInfos.coord % _gameService.game!.gameboard.size;
    int y = simpleLetterInfos.coord ~/ _gameService.game!.gameboard.size;
    int index =
        _gameService.pendingLetters.indexWhere((element) => element.x == x && element.y == y);
    if (index >= 0) {
      _gameService.pendingLetters.removeAt(index);
      _gameService.game!.gameboard.removeLetter(x, y);
      debugPrint(
          "New letter taken: ${_gameService.pendingLetters.map((placement) => "(${placement.x}, ${placement.y}): ${placement.letter}").toList().toString()}");
      _gameService.game!.gameboard.notifyBoardChanged.add(true);
    } else {
      debugPrint("Received sync letter taken that is not in pending letters...");
    }
  }

  startDragSync() async {
    while (_gameService.draggedLetter != null) {
      _socket.emit(
          GameSocketEvent.SendDrag.event,
          DragInfos(_roomService.currentRoom!.id, _socket.id!,
              _gameService.draggedLetter!.character, [], [_windowWidth, _windowHeight]));
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  updateDraggedLetterPosition(Offset globalPosition) {
    debugPrint("(${globalPosition.dx}, ${globalPosition.dy}) in ($_windowWidth, $_windowHeight)}");
  }
}
