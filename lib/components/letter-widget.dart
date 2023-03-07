import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/enums/letter-enum.dart';
import 'package:mobile/domain/models/board-models.dart';

import '../domain/services/game-service.dart';

/// @brief Model for all letter (Visual widget)
class LetterWidget extends StatelessWidget {
  final String value;
  final double widgetSize;

  const LetterWidget(
      {super.key, required this.value, required this.widgetSize});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: widgetSize,
        width: widgetSize,
        child: Card(
          color: Colors.orangeAccent[100],
          child: Center(
              child: Text(
            value,
            style: TextStyle(fontSize: 0.4 * widgetSize, color: Colors.black),
          )),
        ));
  }
}

class DraggedLetter extends StatelessWidget {
  const DraggedLetter({
    super.key,
    required this.value,
    required this.dragKey,
  });

  final GlobalKey dragKey;
  final Letter value;

  @override
  Widget build(BuildContext context) {
    return FractionalTranslation(
        translation: const Offset(0, -0.75),
        child: ClipRRect(
            key: dragKey,
            borderRadius: BorderRadius.circular(12.0),
            child: Padding(
                padding: const EdgeInsets.only(
                    left: 6.0, right: 6.0, top: 2.0, bottom: 0.0),
                child: LetterWidget(
                  value: value.value,
                  widgetSize: 75,
                ))));
  }
}

class BoardLetter extends StatelessWidget {
  final _gameService = GetIt.I.get<GameService>();

  BoardLetter(
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
    return LongPressDraggable(
      data: value,
      feedback: DraggedLetter(value: value, dragKey: dragKey),
      child: LetterWidget(value: value.value, widgetSize: widgetSize),
      onDragStarted: () => _gameService.removeLetterFromBoard(x, y),
      onDraggableCanceled: (_v, _o) =>
          _gameService.placeLetterOnBoard(x, y, value),
    );
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
      feedback: DraggedLetter(value: value, dragKey: dragKey),
      child: LetterWidget(value: value.value, widgetSize: 75),
      onDragStarted: () => _gameService.removeLetterFromEaselAt(index),
      onDraggableCanceled: (_v, _o) => _gameService.addLetterInEasel(value),
    );
  }
}
