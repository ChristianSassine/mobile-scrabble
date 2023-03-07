import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/enums/letter-enum.dart';
import 'package:mobile/domain/models/board-models.dart';
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

  StreamSubscription? easelUpdapte;

  @override
  Widget build(BuildContext context) {
    easelUpdapte ??=
        _gameService.easel.notifyEaselChanged.stream.listen((event) {
          setState(() {});
        });

    return DragTarget<Letter>(
      builder: (context, letters, rejectedItems) {
        return Container(
          height: 83,
          child: Card(
            color: Colors.green[700],
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _gameService.easel
                      .getLetterList()
                      .asMap().entries.map((letter) => EaselLetter(value: letter.value, index: letter.key, dragKey: widget.dragKey, widgetSize: 75,))
                      .toList()
              )),
        );
      },
      onAccept: (letter) => _gameService.addLetterInEasel(letter),
    );
  }
}
