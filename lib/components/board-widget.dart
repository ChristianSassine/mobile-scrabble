import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/components/letter-widget.dart';
import 'package:mobile/domain/enums/letter-enum.dart';
import 'package:mobile/domain/models/game-command-models.dart';
import 'package:mobile/domain/services/clue-service.dart';
import 'package:mobile/domain/services/game-service.dart';
import 'package:mobile/domain/models/board-models.dart';
import 'package:mobile/domain/services/game-sync-service.dart';

class BoardWidget extends StatefulWidget {
  final GlobalKey dragKey;

  const BoardWidget({super.key, required this.dragKey});

  @override
  State<BoardWidget> createState() => _BoardState();
}

class _BoardState extends State<BoardWidget> {
  final _gameService = GetIt.I.get<GameService>();
  final _clueService = GetIt.I.get<ClueService>();

  late StreamSubscription boardUpdate, clueSelectorUpdate;

  PlaceWordCommandInfo? clue;

  @override
  initState() {
    super.initState();

    boardUpdate = _gameService.game!.gameboard.notifyBoardChanged.stream.listen((event) {
      setState(() {});
    });

    clueSelectorUpdate = _clueService.notifyClueSelector.stream.listen((event) {
      setState(() {
        if(_clueService.clues == null || _clueService.clues!.isEmpty) {
          clue = null;
          return;
        }
        clue = _clueService.clues![_clueService.clueSelector];
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    boardUpdate.cancel();
    clueSelectorUpdate.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_gameService.game == null) {
      return const SizedBox();
    }

    double slotSize =
        min(MediaQuery.of(context).size.height, MediaQuery.of(context).size.width) * 0.055;
    int boardSize = _gameService.game!.gameboard.size;

    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
            boardSize,
            (vIndex) => Padding(
                  padding: const EdgeInsets.only(left: 25, right: 25),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        boardSize,
                        (hIndex) => Stack(children: [
                              SlotWidget(
                                  value: _gameService.game!.gameboard.layout.layoutMatrix[vIndex]
                                      [hIndex],
                                  x: hIndex,
                                  y: vIndex),
                              !_gameService.game!.gameboard.isSlotEmpty(hIndex, vIndex)
                                  ? _gameService.isPendingLetter(hIndex, vIndex)
                                      ? PendingBoardLetter(
                                          value:
                                              _gameService.game!.gameboard.getSlot(hIndex, vIndex)!,
                                          dragKey: widget.dragKey,
                                          widgetSize: slotSize,
                                          x: hIndex,
                                          y: vIndex)
                                      : BoardLetter(
                                          value:
                                              _gameService.game!.gameboard.getSlot(hIndex, vIndex)!,
                                          widgetSize: slotSize)
                                  : ((_clueService.isClueLetter(clue, hIndex, vIndex))
                                      ? ClueBoardLetter(
                                          value: _clueService.getClueLetter(clue, hIndex, vIndex)!,
                                          dragKey: widget.dragKey,
                                          widgetSize: slotSize,
                                          x: hIndex,
                                          y: vIndex)
                                      : const SizedBox.shrink())
                            ])).toList(),
                  ),
                )).toList());
  }
}

class SlotWidget extends StatelessWidget {
  final _gameService = GetIt.I.get<GameService>();
  final Modifier value;
  final int x, y;

  SlotWidget({super.key, required this.value, required this.x, required this.y});

  getCardFromModifier(context, value) {
    Color? color;
    String labelKey = "";
    switch (value) {
      case Modifier.NONE:
        color = Colors.brown[200];
        break;
      case Modifier.START:
        color = Colors.yellow;
        break;
      case Modifier.DOUBLE_LETTER:
        color = Colors.blue[100];
        labelKey = "board.double_letter";
        break;
      case Modifier.TRIPLE_LETTER:
        color = Colors.blue[400];
        labelKey = "board.triple_letter";
        break;
      case Modifier.DOUBLE_WORD:
        color = Colors.red[200];
        labelKey = "board.double_word";
        break;
      case Modifier.TRIPLE_WORD:
        color = Colors.red[800];
        labelKey = "board.triple_word";
        break;
    }
    return Card(
        color: color,
        margin: EdgeInsets.zero,
        shape: Border.all(color: Colors.white, width: 2),
        child: Center(
            child: Text(
          FlutterI18n.translate(context, labelKey),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 8, color: Colors.black),
          textAlign: TextAlign.center,
        )));
  }

  Future<Letter?> _promptLetterValue(context) async {
    final formKey = GlobalKey<FormState>();
    final letterInputController = TextEditingController();
    final ValueNotifier<bool> enableConfirm = ValueNotifier(false);

    isInputInvalid(value) =>
        value == null ||
        value.isEmpty ||
        value == "*" ||
        value == "_" ||
        value == "-" ||
        Letter.fromCharacter(value.toUpperCase()) == null;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: Text(FlutterI18n.translate(context, "board.letter_prompt.dialog_title"), style: const TextStyle(color: Colors.black),),
          content: Form(
              key: formKey,
              child: TextFormField(
                controller: letterInputController,
                validator: (value) {
                  if (isInputInvalid(value)) {
                    return FlutterI18n.translate(context, "board.letter_prompt.invalid_letter");
                  }
                  return null;
                },
                onChanged: (value) => enableConfirm.value = !isInputInvalid(value),
              )),
          actions: [
            ValueListenableBuilder<bool>(
              valueListenable: enableConfirm,
              builder: (context, value, child) => ElevatedButton(
                onPressed: value
                    ? () {
                        Navigator.pop(context);
                      }
                    : null,
                child: Text(FlutterI18n.translate(context, "board.letter_prompt.confirm"), style: const TextStyle(color: Colors.black)),
              ),
            ),
          ]),
    );

    return Letter.fromCharacter(letterInputController.text.toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    var slotSize =
        min(MediaQuery.of(context).size.height, MediaQuery.of(context).size.width) * 0.055;

    return SizedBox(
      height: slotSize,
      width: slotSize,
      child: DragTarget<Letter>(
        builder: (context, letters, rejectedItems) {
          if (letters.isEmpty) {
            return getCardFromModifier(context, value);
          } else {
            return Stack(children: [
              getCardFromModifier(context, value),
              GhostLetter(value: letters[0]!, widgetSize: slotSize)
            ]);
          }
        },
        onAccept: (letter) async {
          if (!_gameService.game!.isCurrentPlayersTurn()) {
            _gameService.cancelDragLetter();
            return;
          }

          if (letter == Letter.STAR) {
            Letter? returnedLetter = await _promptLetterValue(context);
            if (returnedLetter == null) {
              // No letter was submitted
              _gameService.cancelDragLetter();
            } else {
              _gameService.placeLetterOnBoard(x, y, returnedLetter, true);
            }
            return;
          }
          _gameService.placeLetterOnBoard(x, y, letter, false);
        },
      ),
    );
  }
}

class BoardLetter extends StatelessWidget {
  const BoardLetter({super.key, required this.value, required this.widgetSize});

  final Letter value;
  final double widgetSize;

  @override
  Widget build(BuildContext context) {
    return LetterWidget(character: value.character, points: value.points, widgetSize: widgetSize);
  }
}

class PendingBoardLetter extends StatelessWidget {
  final _gameService = GetIt.I.get<GameService>();
  final _gameSyncService = GetIt.I.get<GameSyncService>();

  PendingBoardLetter(
      {super.key,
      required this.value,
      required this.dragKey,
      required this.widgetSize,
      required this.x,
      required this.y});

  final Letter value;
  final GlobalKey dragKey;
  final double widgetSize;
  final int x, y;

  @override
  Widget build(BuildContext context) {
    return _gameService.isPlacedLetterRemovalValid(x, y)
        ? LongPressDraggable(
            data: value,
            delay: const Duration(milliseconds: 0),
            feedback: DraggedLetter(value: value, dragKey: dragKey),
            child: LetterWidget(
              character: value.character,
              points: value.points,
              widgetSize: widgetSize,
              color: Colors.orange[100],
            ),
            onDragStarted: () => _gameService.dragLetterFromBoard(x, y),
            onDraggableCanceled: (v, o) => _gameService.cancelDragLetter(),
            onDragUpdate: (detail) =>
                _gameSyncService.updateDraggedLetterPosition(detail.globalPosition),
          )
        : LetterWidget(
            character: value.character,
            points: value.points,
            widgetSize: widgetSize,
            color: Colors.orange[100],
          );
  }
}

class ClueBoardLetter extends StatelessWidget {
  const ClueBoardLetter(
      {super.key,
      required this.value,
      required this.dragKey,
      required this.widgetSize,
      required this.x,
      required this.y});

  final Letter value;
  final GlobalKey dragKey;
  final double widgetSize;
  final int x, y;

  @override
  Widget build(BuildContext context) {
    return LetterWidget(
      character: value.character,
      points: value.points,
      widgetSize: widgetSize,
      opacity: 0.5,
      color: Colors.lightBlueAccent[100],
    );
  }
}
