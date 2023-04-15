import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/enums/letter-enum.dart';
import 'package:mobile/domain/services/game-service.dart';
import 'package:mobile/domain/services/game-sync-service.dart';
import 'package:mobile/domain/services/room-service.dart';
import 'package:mobile/domain/services/user-service.dart';
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
    _actuateVirtualEasel();
  }

  void _moveGhostLetterAt(int index) {
    int ghostLetterIndex = _visualLetters.indexOf(Letter.EMPTY);
    if (ghostLetterIndex == index) return;

    if (ghostLetterIndex >= 0) {
      debugPrint(
          "[EASEL WIDGET] Ghost letter will be moved from ${_visualLetters.indexOf(Letter.EMPTY)} to $index");
      setState(() {
        Letter ghostLetter = _visualLetters.removeAt(ghostLetterIndex);
        _visualLetters.insert(index, ghostLetter);
      });
    } else if (_visualLetters.length < _gameService.game!.currentPlayer.easel.maxSize) {
      debugPrint("[EASEL WIDGET] Ghost letter will be created at $index");
      setState(() {
        _visualLetters.insert(index, Letter.EMPTY);
      });
    }
  }

  void _moveGhostLetterFromDragOffset(Offset offset) {
    _moveGhostLetterAt(
        offset.dx < MediaQuery.of(context).size.width / 2 ? 0 : _visualLetters.length - 1);
  }

  void _onEaselDrop(letter) {
    debugPrint(
        "[EASEL WIDGET] Letter '$letter' was dropped on the easel and will replace ghost letter at ${_visualLetters.indexOf(Letter.EMPTY)}");
    int letterIndex = _visualLetters.indexOf(Letter.EMPTY);
    if (letterIndex >= 0) {
      _gameService.addLetterInEaselAt(letterIndex, letter);
    } else {
      _gameService.addLetterInEasel(letter);
    }
  }

  _removeGhostLetter() {
    debugPrint("[EASEL WIDGET] Remove ghost letter at ${_visualLetters.indexOf(Letter.EMPTY)}");
    setState(() {
      _visualLetters.remove(Letter.EMPTY);
    });
  }

  _actuateVirtualEasel(){
    List<Letter> actualEasel = _gameService.observerView == null
        ? _gameService.game!.currentPlayer.easel.getLetterList()
        : _gameService.observerView!.easel.getLetterList();

    _visualLetters = actualEasel.toList();
  }

  @override
  void initState() {
    super.initState();

    easelUpdate =
        _gameService.notifyEaselChanged.stream.listen((letterIndex) {
      setState(() {
        _actuateVirtualEasel();
      });
    });

    boardUpdate = _gameService.game!.gameboard.notifyBoardChanged.stream.listen((even) {
      setState(() {
        // Executed for when a new letter is placed
        _actuateVirtualEasel();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    easelUpdate!.cancel();
    boardUpdate!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<Letter>(
        builder: (context, letters, rejectedItems) {
          return SizedBox(
            height:
                min(MediaQuery.of(context).size.height, MediaQuery.of(context).size.width) * 0.1,
            child: Card(
                color: Colors.green[700],
                margin: EdgeInsets.zero,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _visualLetters
                        .asMap()
                        .entries
                        .map(
                          (letter) => DragTarget(
                            builder: (BuildContext context, List<Object?> candidateData,
                                List<dynamic> rejectedData) {
                              return EaselLetter(
                                value: letter.value,
                                index: letter.key,
                                dragKey: widget.dragKey,
                                widgetSize: min(MediaQuery.of(context).size.height,
                                        MediaQuery.of(context).size.width) *
                                    0.1,
                              );
                            },
                            onMove: (_) => // For when dragged letter is held on top of easel letter
                                _moveGhostLetterAt(letter.key),
                            onAccept: _onEaselDrop,
                            onLeave: (_) => _removeGhostLetter(),
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
  final _gameSyncService = GetIt.I.get<GameSyncService>();

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
    if (_gameService.observerView != null) {
      return LetterWidget(
        character: value.character,
        points: value.points,
        widgetSize: widgetSize,
        opacity: value != Letter.EMPTY ? 1 : 0.75,
      );
    } else {
      return LongPressDraggable(
        data: value,
        delay: const Duration(milliseconds: 0),
        feedback: DraggedLetter(value: value, dragKey: dragKey),
        child: LetterWidget(
          character: value.character,
          points: value.points,
          widgetSize: widgetSize,
          opacity: value != Letter.EMPTY ? 1 : 0.75,
        ),
        onDragStarted: () => _gameService.dragLetterFromEasel(index),
        onDraggableCanceled: (v, o) => _gameService.cancelDragLetter(),
        onDragUpdate: (detail) => _gameSyncService.updateDraggedLetterPosition(detail.globalPosition),
      );
    }
  }
}
