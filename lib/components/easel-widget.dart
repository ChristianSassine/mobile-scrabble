import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
            children: _gameService.easel
                .getLetterList()
                .map((letter) => EaselLetter(value: letter, dragKey: widget.dragKey, widgetSize: 75,))
                .toList()
            ));
  }
}
