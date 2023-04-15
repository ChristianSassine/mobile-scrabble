import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:mobile/domain/enums/letter-enum.dart';
import 'package:mobile/domain/enums/socket-events-enum.dart';
import 'package:mobile/domain/models/game-command-models.dart';
import 'package:mobile/domain/services/game-service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart';

class ClueService {
  final _socket = GetIt.I.get<Socket>();
  final _gameService = GetIt.I.get<GameService>();

  List<PlaceWordCommandInfo>? clues;
  int clueSelector = 0;

  Subject<int> notifyNewClues = PublishSubject();
  Subject<int> notifyClueSelector = PublishSubject();

  late StreamSubscription<bool> nextTurnSub;

  ClueService() {
    nextTurnSub = _gameService.notifyGameInfoChange.listen((value) {
      if (value) {
        resetClues();
      }
    });
    _initSocketListenners();
  }

  _initSocketListenners() {
    _socket.on(
        GameSocketEvent.ClueCommand.event,
        (clueCommandInfos) => _receiveClues(clueCommandInfos
            .map<PlaceWordCommandInfo>((commandInfo) => PlaceWordCommandInfo.fromJson(commandInfo))
            .toList()));
  }

  fetchClues() {
    _socket.emit(GameSocketEvent.ClueCommand.event);
  }

  resetClues() {
    clues = null;
    notifyNewClues.add(0);
    notifyClueSelector.add(0);
  }

  incClueSelector() {
    if (clues == null) return;

    clueSelector = (clueSelector + 1) % clues!.length;
    notifyClueSelector.add(clueSelector);
  }

  decClueSelector() {
    if (clues == null) return;

    clueSelector = (clueSelector - 1) % clues!.length;
    notifyClueSelector.add(clueSelector);
  }

  static bool isClueLetter(PlaceWordCommandInfo? clue, int x, int y) {
    if (clue == null) return false;

    if (clue.isHorizontal == true) {
      return clue.firstCoordinate.y == y &&
          clue.firstCoordinate.x <= x &&
          x < clue.firstCoordinate.x + clue.letters.length;
    } else {
      return clue.firstCoordinate.x == x &&
          clue.firstCoordinate.y <= y &&
          y < clue.firstCoordinate.y + clue.letters.length;
    }
  }

  static Letter? getClueLetter(PlaceWordCommandInfo? clue, int x, int y) {
    if (clue == null) return null;

    return Letter.fromCharacter((clue.isHorizontal == true
            ? clue.letters[x - clue.firstCoordinate.x]
            : clue.letters[y - clue.firstCoordinate.y])
        .toUpperCase());
  }

  placeClueSelection() {
    if (clues == null) return;

    var clue = clues![clueSelector];

    // Removing already placed letters in clue
    var position = clue.firstCoordinate;
    int letterCount = clue.letters.length;
    for (var letterIndex = 0; letterIndex < letterCount; letterIndex++) {
      if (_gameService.game!.gameboard.isSlotEmpty(position.x, position.y)) {
        _gameService.placeLetterOnBoard(
            position.x,
            position.y,
            Letter.fromCharacter(clue.letters[letterIndex].toUpperCase())!,
            clue.letters[letterIndex] == clue.letters[letterIndex].toUpperCase());
      }
      if (clue.isHorizontal == true) {
        position.x++;
      } else {
        position.y++;
      }
    }

    _gameService.confirmWordPlacement();
  }

  _receiveClues(List<PlaceWordCommandInfo> incomingClues) {
    clues = incomingClues;
    clueSelector = 0;
    notifyNewClues.add(incomingClues.length);
    notifyClueSelector.add(clueSelector);
  }
}
