import 'dart:async';

import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/enums/letter-enum.dart';
import 'package:mobile/domain/services/game-service.dart';

class LetterReserve extends StatefulWidget {
  final GlobalKey draggableKey;

  const LetterReserve({Key? key, required this.draggableKey}) : super(key: key);

  @override
  State<LetterReserve> createState() => _LetterReserveState();
}

class _LetterReserveState extends State<LetterReserve> {
  final GameService _gameService = GetIt.I.get<GameService>();

  List<Letter> lettersToExchange = [];
  bool draggingMode = false;

  late StreamSubscription<bool> subDrag;

  @override
  void initState() {
    super.initState();
    subDrag = _gameService.notifyGameInfoChange.listen((gameInfo) {
      if (gameInfo) {
        setState(() {
          lettersToExchange = [];
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    subDrag.cancel();
  }

  _promptExchangeConfirmation(context) async {
    if (await confirm(
      context,
      textOK: Text(FlutterI18n.translate(context, "form.yes"), style: const TextStyle(color: Colors.black)),
      textCancel: Text(FlutterI18n.translate(context, "form.no"), style: const TextStyle(color: Colors.black)),
      title: Text(FlutterI18n.translate(context, "game.exchange_letter_prompt"), style: const TextStyle(color: Colors.black)),
      content: Text(lettersToExchange.toString(), style: TextStyle(fontSize: 20, color: Colors.black)),
    )) {
      _gameService.exchangeLetters(lettersToExchange);
    } else {
      for (var element in lettersToExchange) {
        _gameService.addLetterInEasel(element);
      }
      lettersToExchange.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<Letter>(
      builder: (context, letters, rejectedItems) {
        return SizedBox(
            width: 115,
            height: 95,
            child: GestureDetector(
                onTap: (lettersToExchange.isNotEmpty ? () => _promptExchangeConfirmation(context) : null),
                child: Card(
                    color: letters.isNotEmpty
                        ? Colors.orange
                        : (lettersToExchange.isNotEmpty ? Colors.green : Colors.lightGreen[50]),
                    margin: const EdgeInsets.all(10),
                    child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: (!_gameService.game!.isCurrentPlayersTurn() || (widget.draggableKey.currentWidget == null &&
                                lettersToExchange.isEmpty))
                            ? Column(children: [
                                Text(
                                  FlutterI18n.translate(context, "game.reserve"),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
                                ),
                                const SizedBox(height: 5),
                                Text("${_gameService.game!.reserveLetterCount.toString()} ${FlutterI18n.translate(context, "game.letter")}s", style: const TextStyle(color: Colors.black))
                              ])
                            : (lettersToExchange.isEmpty)
                                ? Column(children: [
                                    Image(
                                        image: const AssetImage("assets/images/exchange.png"),
                                        width: (lettersToExchange.isNotEmpty) ? 25 : 38),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    if (lettersToExchange.isNotEmpty)
                                      Text("${lettersToExchange.length.toString()} ${FlutterI18n.translate(context, "game.letter")}s", style: const TextStyle(color: Colors.black))
                                  ])
                                : Column(
                                    children: [
                                      Image(
                                          image: const AssetImage("assets/images/exchange.png"),
                                          width: (lettersToExchange.isNotEmpty) ? 25 : 38),
                                      const SizedBox(
                                        height: 2,
                                      ),
                                      if (lettersToExchange.isNotEmpty)
                                        Text("${lettersToExchange.length.toString()} ${FlutterI18n.translate(context, "game.letter")}s", style: const TextStyle(color: Colors.black))
                                    ],
                                  )))));
      },
      onAccept: (letter) => lettersToExchange.add(letter),
    );
  }
}
