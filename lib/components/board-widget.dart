import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/services/game-service.dart';

import '../domain/models/board-models.dart';

class BoardWidget extends StatefulWidget {
  final GlobalKey dragKey;

  const BoardWidget({super.key, required this.dragKey});

  @override
  State<BoardWidget> createState() => _BoardState();
}

class _BoardState extends State<BoardWidget> {
  final _gameService = GetIt.I.get<GameService>();

  @override
  Widget build(BuildContext context) {
    int boardSize = _gameService.gameboard.size;
    return Card(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                boardSize,
                (vIndex) => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                          boardSize,
                          (hIndex) => SlotWidget(
                              value: _gameService.gameboard.layout
                                  .layoutMatrix[vIndex][hIndex])).toList(),
                    )).toList()));
  }
}

class SlotWidget extends StatelessWidget {
  final Modifier value;

  const SlotWidget({super.key, required this.value});

  getCardFromModifier(context, value) {
    Color? color;
    String labelKey = "";
    switch (value) {
      case Modifier.NONE:
        color = Colors.brown[100];
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
        shape: Border.all(color: Colors.black45, width: 0.05),
        child: Center(
            child: Text(
          FlutterI18n.translate(context, labelKey),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9), textAlign: TextAlign.center,
        )));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 35, width: 35, child: getCardFromModifier(context, value));
  }
}
