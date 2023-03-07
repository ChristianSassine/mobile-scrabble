import 'package:mobile/domain/models/board-models.dart';
import 'package:mobile/domain/models/easel-model.dart';

import '../enums/letter-enum.dart';

class GameService {

  final Board gameboard = Board(15);
  final Easel easel = Easel(7);

  GameService(){
    easel.addLetter(Letter.A);
    easel.addLetter(Letter.B);
    easel.addLetter(Letter.C);
    easel.addLetter(Letter.D);
    easel.addLetter(Letter.E);
    easel.addLetter(Letter.F);
    easel.addLetter(Letter.G);
  }

  void placeLetterOnBoard(int x, int y, Letter letter){
    gameboard.placeLetter(x, y, letter);

    //TODO: CALL SERVER IMPLEMENTATION FOR SYNC
  }

  /// @return the removed letter
  Letter? removeLetterFromBoard(int x, int y){
    return gameboard.removeLetter(x, y);

    //TODO: CALL SERVER IMPLEMENTATION FOR SYNC
  }

  void addLetterInEasel(Letter letter){
    easel.addLetter(letter);

    //TODO: CALL SERVER IMPLEMENTATION FOR SYNC
  }

  /// @return null if index is out of bound
  Letter? removeLetterFromEaselAt(int index){
    Letter? removedLetter = easel.removeLetterAt(index);

    //TODO: CALL SERVER IMPLEMENTATION FOR SYNC

    return removedLetter;
  }

  /// @return null if letter is not in easel
  Letter? removeLetterFromEasel(Letter letter){
    Letter? removedLetter = easel.removeLetter(letter);

    //TODO: CALL SERVER IMPLEMENTATION FOR SYNC

    return removedLetter;
  }

  void fillEaselWithReserve(){
    //TODO: IMPLEMENT
  }

}
