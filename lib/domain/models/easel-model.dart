import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/services/game-service.dart';
import 'package:rxdart/rxdart.dart';

import '../enums/letter-enum.dart';

class Easel {
  final _gameService = GetIt.I.get<GameService>();

  List<Letter> _letters = [];

  final int maxSize;

  Easel(this.maxSize);

  void addLetterAt(int index, Letter letter) {
    if (_letters.length >= maxSize) {
      debugPrint("You tried to add letter $letter, but easel is full");
      return;
    }

    _letters.insert(index, letter);
    _gameService.notifyEaselChanged.add(index);
  }

  void addLetter(Letter letter) {
    addLetterAt(_letters.length, letter);
  }

  Letter? removeLetterAt(int index) {
    if (0 > index || index > _letters.length) {
      debugPrint(
          "You tried to remove letter at index $index, but the easel contains only ${_letters.length} letters");
      return null;
    }

    Letter letter = _letters.removeAt(index);
    _gameService.notifyEaselChanged.add(index);
    return letter;
  }

  Letter? removeLetter(Letter letter) {
    int index = _letters.indexOf(letter);

    if (index < 0) {
      debugPrint(
          "You tried to remove letter '$letter', but only have those letters: ${_letters.toString()}");
      return null;
    }

    _letters.remove(letter);
    _gameService.notifyEaselChanged.add(index);
    return letter;
  }

  List<Letter> getLetterList() {
    return _letters;
  }

  void updateFromRack(List<Letter> rack) {
    _letters = rack;
    _gameService.notifyEaselChanged.add(0);
  }
}
