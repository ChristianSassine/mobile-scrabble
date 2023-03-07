
import 'package:flutter/cupertino.dart';
import 'package:mobile/domain/models/board-models.dart';
import 'package:rxdart/rxdart.dart';

import '../enums/letter-enum.dart';

class Easel{

  Subject<bool> notifyEaselChanged = PublishSubject();

  final List<Letter> _letters = [];

  final int size;

  Easel(this.size);

  void addLetter(Letter letter){
    if (_letters.length >= size) {
      debugPrint("You tried to add letter $letter, but easel is full");
      return;
    }

    _letters.add(letter);
    notifyEaselChanged.add(true);
  }

  Letter? removeLetterAt(int index){
    if(0 > index || index > _letters.length){
      debugPrint("You tried to remove letter at index $index, but the easel contains only ${_letters.length} letters");
      return null;
    }

    Letter letter = _letters.removeAt(index);
    notifyEaselChanged.add(true);
    return letter;
  }

  Letter? removeLetter(Letter letter){
    if(!_letters.contains(letter)){
      debugPrint("You tried to remove letter '$letter', but only have those letters: ${_letters.toString()}");
      return null;
    }

    _letters.remove(letter);
    notifyEaselChanged.add(true);
    return letter;
  }

  List<Letter> getLetterList(){
    return _letters;
  }
}
