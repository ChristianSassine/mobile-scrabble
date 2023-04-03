import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/components/letter-widget.dart';
import 'package:mobile/domain/enums/letter-enum.dart';
import 'package:mobile/domain/services/game-service.dart';
import 'package:mobile/domain/models/board-models.dart';

class BoardWidget extends StatefulWidget {
  final GlobalKey dragKey;

  const BoardWidget({super.key, required this.dragKey});

  @override
  State<BoardWidget> createState() => _BoardState();
}

class _BoardState extends State<BoardWidget> {
  final _gameService = GetIt.I.get<GameService>();

  late StreamSubscription boardUpdate;

  @override
  initState() {
    super.initState();

    boardUpdate = _gameService.game!.gameboard.notifyBoardChanged.stream.listen((event) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    boardUpdate.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if(_gameService.game == null){
      return const SizedBox();
    }

    double slotSize = min(MediaQuery.of(context).size.height, MediaQuery.of(context).size.width) * 0.055;
    int boardSize = _gameService.game!.gameboard.size;

    return Card(
      color: Colors.green[900],
      shape: Border.all(width: 0),
      child: Column(
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
                                    value: _gameService.game!.gameboard.layout.layoutMatrix[hIndex]
                                        [vIndex],
                                    x: vIndex,
                                    y: hIndex),
                                !_gameService.game!.gameboard.isSlotEmpty(vIndex, hIndex)
                                    ? _gameService.isPendingLetter(vIndex, hIndex)
                                        ? PendingBoardLetter(
                                            value: _gameService.game!.gameboard.getSlot(vIndex, hIndex)!,
                                            dragKey: widget.dragKey,
                                            widgetSize: slotSize,
                                            x: vIndex,
                                            y: hIndex)
                                        : BoardLetter(
                                            value: _gameService.game!.gameboard.getSlot(vIndex, hIndex)!,
                                            widgetSize: slotSize)
                                    : const SizedBox.shrink()
                              ])).toList(),
                    ),
                  )).toList()),
    );
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 8),
          textAlign: TextAlign.center,
        )));
  }

  @override
  Widget build(BuildContext context) {
    var slotSize = min(MediaQuery.of(context).size.height, MediaQuery.of(context).size.width) * 0.055;

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
        onAccept: (letter) => _gameService.placeLetterOnBoard(x, y, letter),
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
              highlighted: true,
            ),
            onDragStarted: () => _gameService.dragLetterFromBoard(x, y),
            onDraggableCanceled: (v, o) => _gameService.cancelDragLetter(),
          )
        : LetterWidget(
            character: value.character,
            points: value.points,
            widgetSize: widgetSize,
            highlighted: true,
          );
  }
}
