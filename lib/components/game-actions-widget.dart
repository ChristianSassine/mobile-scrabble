import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/services/clue-service.dart';
import 'package:mobile/domain/services/game-service.dart';

class ClueControl extends StatefulWidget {
  final bool vertical;

  const ClueControl({Key? key, required this.vertical}) : super(key: key);

  @override
  State<ClueControl> createState() => _ClueControlState();
}

class _ClueControlState extends State<ClueControl> {
  final _gameService = GetIt.I.get<GameService>();
  final _clueService = GetIt.I.get<ClueService>();

  int clueCount = 0;

  late StreamSubscription<int> clueCountSub;

  @override
  void initState() {
    super.initState();
    clueCountSub = _clueService.notifyNewClues.stream.listen((event) {
      setState(() {
        clueCount = event;
      });
    });
  }

  @override
  void dispose() {
    clueCountSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (clueCount == 0) {
      return SizedBox(
        width: !widget.vertical ? 175 : 175,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[400]),
            onPressed:
                !_gameService.game!.isCurrentPlayersTurn() ? null : () => {_clueService.fetchClues()},
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20.0),
              child: Text(FlutterI18n.translate(context, "game.clue")),
            )),
      );
    } else {
      Widget prevClueBut = IconButton(
        onPressed: !_gameService.game!.isCurrentPlayersTurn()
            ? null
            : () => {_clueService.decClueSelector()},
        icon: Icon((!widget.vertical) ? Icons.chevron_left : Icons.expand_less),
      );
      Widget confirmBut = SizedBox(
          width: !widget.vertical ? null : 175,
          child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green[400]),
          onPressed: !_gameService.game!.isCurrentPlayersTurn()
              ? null
              : () => {_clueService.placeClueSelection()},
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Text(FlutterI18n.translate(context, "board.letter_prompt.confirm")),
          )));
      Widget nextClueBut = IconButton(
        onPressed: !_gameService.game!.isCurrentPlayersTurn()
            ? null
            : () => {_clueService.incClueSelector()},
        icon: Icon((!widget.vertical) ? Icons.chevron_right : Icons.expand_more),
      );
      return SizedBox(
          width: (!widget.vertical) ? 195.4 : 175,
          height: (!widget.vertical) ? 58 : 155,
          child: (!widget.vertical)
              ? Row(
                  children: [prevClueBut, confirmBut, nextClueBut],
                )
              : Column(
                  children: [prevClueBut, confirmBut, nextClueBut],
                ));
    }
  }
}

class GameActions extends StatefulWidget {
  bool vertical;

  GameActions({Key? key, required this.vertical}) : super(key: key);

  @override
  State<GameActions> createState() => _GameActionsState();
}

class _GameActionsState extends State<GameActions> {
  final _gameService = GetIt.I.get<GameService>();

  late StreamSubscription _gameInfoUpdate;

  @override
  initState() {
    super.initState();
    _gameInfoUpdate = _gameService.notifyGameInfoChange.stream.listen((event) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _gameInfoUpdate.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (_gameService.game == null) return const SizedBox.shrink();
    Widget skipButton = ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        onPressed:
            _gameService.game!.isCurrentPlayersTurn() ? () => {_gameService.skipTurn()} : null,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 17.0),
          child: Icon(Icons.skip_next_rounded),
        ));

    Widget placeButton = SizedBox(
      width: !widget.vertical ? 250 : 175,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green[400]),
          onPressed: !_gameService.game!.isCurrentPlayersTurn() || _gameService.pendingLetters.isEmpty
              ? null
              : () => {_gameService.confirmWordPlacement()},
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Text(FlutterI18n.translate(context, "game.place")),
          )),
    );

    if (!widget.vertical) {
      return Column(
        children: [
          Row(children: [
            ClueControl(
              vertical: widget.vertical,
            ),
            SizedBox(width: 10),
            skipButton
          ]),
          SizedBox(height: 10),
          placeButton
        ],
      );
    } else {
      return SizedBox(
          width: 175,
          child: Column(children: [
            skipButton,
            SizedBox(height: 25),
            ClueControl(vertical: widget.vertical),
            SizedBox(height: 25),
            placeButton
          ]));
    }
  }
}
