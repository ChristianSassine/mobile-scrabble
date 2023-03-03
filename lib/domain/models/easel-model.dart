
import 'package:flutter/cupertino.dart';
import 'package:mobile/domain/models/board-models.dart';
import 'package:rxdart/rxdart.dart';

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
  }

  Letter? removeLetterAt(int index){
    if(0 > index || index > _letters.length){
      debugPrint("You tried to remove letter at index $index, but the easel contains only ${_letters.length} letters");
      return null;
    }
    return _letters.removeAt(index);
  }

  Letter? removeLetter(Letter letter){
    if(!_letters.contains(letter)){
      debugPrint("You tried to remove letter '$letter', but only have those letters: ${_letters.toString()}");
      return null;
    }
    _letters.remove(letter);
    return letter;
  }

  List<Letter> getLetterList(){
    return _letters;
  }
}
