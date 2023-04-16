import 'dart:async';

import 'package:flutter/material.dart';
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
  List<List<Coordinate>>? _alreadyPlacedLetters;
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
    _gameService.cancelPendingLetters();
  }

  resetClues() {
    clues = null;
    _alreadyPlacedLetters = null;
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

  bool isClueLetter(PlaceWordCommandInfo? clue, int x, int y) {
    if (clue == null) return false;

    if (clue.isHorizontal == true) {
      return clue.firstCoordinate.y == y &&
          clue.firstCoordinate.x <= x &&
          x <
              clue.firstCoordinate.x +
                  clue.letters.length +
                  _alreadyPlacedLetters![clueSelector].length;
    } else {
      return clue.firstCoordinate.x == x &&
          clue.firstCoordinate.y <= y &&
          y <
              clue.firstCoordinate.y +
                  clue.letters.length +
                  _alreadyPlacedLetters![clueSelector].length;
    }
  }

  Letter? getClueLetter(PlaceWordCommandInfo? clue, int x, int y) {
    if (clue == null) return null;

    int alreadyPlaceLetterCount = _alreadyPlacedLetters![clueSelector]
        .where((element) => element.x <= x && element.y <= y)
        .toList()
        .length;

    return Letter.fromCharacter((clue.isHorizontal == true
            ? clue.letters[x - alreadyPlaceLetterCount - clue.firstCoordinate.x]
            : clue.letters[y - alreadyPlaceLetterCount - clue.firstCoordinate.y])
        .toUpperCase());
  }

  placeClueSelection() {
    if (clues == null) return;

    var clue = clues![clueSelector];
    clue.letters = clue.letters
        .map((letter) =>
            letter.toLowerCase() == letter ? letter.toUpperCase() : letter.toLowerCase())
        .toList();

    _socket.emit(GameSocketEvent.PlaceWordCommand.event, clues![clueSelector]);
  }

  _receiveClues(List<PlaceWordCommandInfo> incomingClues) {
    clues = incomingClues;
    _alreadyPlacedLetters = incomingClues.map<List<Coordinate>>((clue) {
      List<Coordinate> alreadyPlaced = [];
      for (int letterIndex = 0;
          letterIndex < clue.letters.length;
          letterIndex++) {
        Coordinate position = (clue.isHorizontal == true)
            ? Coordinate(clue.firstCoordinate.x + letterIndex + alreadyPlaced.length, clue.firstCoordinate.y)
            : Coordinate(clue.firstCoordinate.x, clue.firstCoordinate.y + letterIndex  + alreadyPlaced.length);
        if(!_gameService.game!.gameboard.isSlotValid(position.x, position.y)) break;
        if (!_gameService.game!.gameboard.isSlotEmpty(position.x, position.y)) {
          alreadyPlaced.add(position);
          letterIndex--;
        }
      }
      return alreadyPlaced;
    }).toList();
    clueSelector = 0;
    notifyNewClues.add(incomingClues.length);
    notifyClueSelector.add(clueSelector);
  }
}
