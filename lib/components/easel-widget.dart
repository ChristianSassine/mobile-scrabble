import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/enums/letter-enum.dart';
import 'package:mobile/domain/services/game-service.dart';
import 'letter-widget.dart';

class EaselWidget extends StatefulWidget {
  final GlobalKey dragKey;

  const EaselWidget({super.key, required this.dragKey});

  @override
  State<EaselWidget> createState() => _EaselState();
}

class _EaselState extends State<EaselWidget> {
  final _gameService = GetIt.I.get<GameService>();

  late List<Letter> _visualLetters;

  StreamSubscription? easelUpdate, boardUpdate;

  _EaselState() {
    _visualLetters = _gameService.easel.getLetterList().toList();
  }

  void _moveGhostLetterAt(int index) {
    int ghostLetterIndex = _visualLetters.indexOf(Letter.EMPTY);
    if (ghostLetterIndex == index) return;

    if (ghostLetterIndex >= 0) {
      setState(() {
        Letter ghostLetter = _visualLetters.removeAt(ghostLetterIndex);
        _visualLetters.insert(index, ghostLetter);
      });
    } else if (_visualLetters.length < _gameService.easel.maxSize) {
      setState(() {
        _visualLetters.insert(index, Letter.EMPTY);
      });
    }
  }

  void _moveGhostLetterFromDragOffset(Offset offset) {
    _moveGhostLetterAt(
        offset.dx < MediaQuery.of(context).size.width / 2
            ? 0
            : _visualLetters.length - 1);
  }

  void _onEaselDrop(letter) {
    int letterIndex = _visualLetters.indexOf(Letter.EMPTY);
    if (letterIndex >= 0) {
      _gameService.addLetterInEaselAt(letterIndex, letter);
    } else {
      _gameService.addLetterInEasel(letter);
    }
  }

  _removeGhostLetter() {
    setState(() {
      _visualLetters.remove(Letter.EMPTY);
    });
  }

  @override
  Widget build(BuildContext context) {
    easelUpdate ??=
        _gameService.easel.notifyEaselChanged.stream.listen((letterIndex) {
      setState(() {
        List<Letter> actualEasel = _gameService.easel.getLetterList();

        // Letter added to easel or
        if (actualEasel.length >= _visualLetters.length) {
          _visualLetters = actualEasel.toList();
        } else {
          _visualLetters[letterIndex] = Letter.EMPTY;
        }
      });
    });

    boardUpdate ??=
        _gameService.gameboard.notifyBoardChanged.stream.listen((even) {
      setState(() {
        // Executed for when a new letter is placed
        _visualLetters = _gameService.easel.getLetterList().toList();
      });
    });

    return DragTarget<Letter>(
        builder: (context, letters, rejectedItems) {
          return Container(
            height: 83,
            child: Card(
                color: Colors.green[700],
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _visualLetters
                        .asMap()
                        .entries
                        .map(
                          (letter) => DragTarget(
                            builder: (BuildContext context,
                                List<Object?> candidateData,
                                List<dynamic> rejectedData) {
                              return EaselLetter(
                                value: letter.value,
                                index: letter.key,
                                dragKey: widget.dragKey,
                                widgetSize: 75,
                              );
                            },
                            onMove: (_) => // For when dragged letter is held on top of easel letter
                                _moveGhostLetterAt(letter.key),
                            onAccept: _onEaselDrop,
                          ),
                        )
                        .toList())),
          );
        },
        onAccept: _onEaselDrop,
        onLeave: (_) => _removeGhostLetter(),
        onMove: (_) => _moveGhostLetterFromDragOffset(_.offset));
  }
}

class EaselLetter extends StatelessWidget {
  final _gameService = GetIt.I.get<GameService>();

  EaselLetter(
      {super.key,
        required this.value,
        required this.index,
        required this.dragKey,
        required this.widgetSize});

  final Letter value;
  final int index;
  final GlobalKey dragKey;
  final double widgetSize;

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable(
      data: value,
      delay: const Duration(milliseconds: 100),
      feedback: DraggedLetter(value: value, dragKey: dragKey),
      child: LetterWidget(character: value.character, points: value.points, widgetSize: 75, opacity: value != Letter.EMPTY ? 1 : 0.75,),
      onDragStarted: () => _gameService.dragLetterFromEasel(index),
      onDraggableCanceled: (v, o) => _gameService.cancelDragLetterFromEasel(),
    );
  }
}

