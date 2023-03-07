import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/components/letter-widget.dart';
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

  StreamSubscription? boardUpdate;

  @override
  Widget build(BuildContext context) {
    boardUpdate ??=
        _gameService.gameboard.notifyBoardChanged.stream.listen((event) {
      setState(() {});
    });

    int boardSize = _gameService.gameboard.size;
    return Card(
        color: Colors.green[900],
        margin: EdgeInsets.all(10),
        shape: Border.all(color: Colors.red, width: 2),
        child: Container(
          height: 620,
          width: 620,
          child: Card(
            color: Colors.brown[500],
            margin: EdgeInsets.all(10),
            shape: Border.all(width: 0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    boardSize,
                    (vIndex) => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                              boardSize,
                              (hIndex) =>
                                  // _gameService.gameboard
                                  //                                   //         .isSlotEmpty(vIndex, hIndex)
                                  //                                   //     ?
                                  Stack(children: [
                                    SlotWidget(
                                        value: _gameService.gameboard.layout
                                            .layoutMatrix[hIndex][vIndex],
                                        x: vIndex,
                                        y: hIndex),
                                    !_gameService.gameboard
                                            .isSlotEmpty(vIndex, hIndex)
                                        ? BoardLetter(
                                            value: _gameService.gameboard
                                                .getSlot(vIndex, hIndex)!,
                                            dragKey: widget.dragKey,
                                            widgetSize: 35)
                                        : const SizedBox.shrink()
                                  ])
                              // : BoardLetter(
                              //     value: _gameService.gameboard
                              //         .getSlot(vIndex, hIndex)!,
                              //     dragKey: widget.dragKey,
                              //   )
                              ).toList(),
                        )).toList()),
          ),
        ));
  }
}

class SlotWidget extends StatelessWidget {
  final _gameService = GetIt.I.get<GameService>();
  final Modifier value;
  final int x, y;

  SlotWidget(
      {super.key, required this.value, required this.x, required this.y});

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
    return SizedBox(
      height: 35,
      width: 35,
      child: DragTarget<Letter>(
          builder: (context, letters, rejectedItems) {
            return getCardFromModifier(context, value);
          },
          onAccept: (letter) => _gameService.placeLetterOnBoard(x, y, letter)),
    );
  }
}
