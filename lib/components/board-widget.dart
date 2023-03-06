import 'package:flutter/material.dart';
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
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                boardSize,
                (vIndex) => Column(
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

  getCardFromModifier(value) {
    Color? color;
    switch (value) {
      case Modifier.NONE:
        color = Colors.brown[100];
        break;
      case Modifier.START:
        color = Colors.yellow;
        break;
      case Modifier.DOUBLE_LETTER:
        color = Colors.blue[100];
        break;
      case Modifier.TRIPLE_LETTER:
        color = Colors.blue[400];
        break;
      case Modifier.DOUBLE_WORD:
        color = Colors.red[200];
        break;
      case Modifier.TRIPLE_WORD:
        color = Colors.red[800];
        break;
    }
    return Card(color: color, child: Center());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.5),
      child: SizedBox(height: 30, width: 30, child: getCardFromModifier(value)),
    );
  }
}
