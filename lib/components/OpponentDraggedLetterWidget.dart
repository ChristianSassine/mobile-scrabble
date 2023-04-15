import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/components/letter-widget.dart';
import 'package:mobile/domain/models/letter-synchronisation-model.dart';
import 'package:mobile/domain/services/game-sync-service.dart';

class OpponentDraggedLetterWidget extends StatefulWidget {
  const OpponentDraggedLetterWidget({Key? key}) : super(key: key);

  @override
  State<OpponentDraggedLetterWidget> createState() => _OpponentDraggedLetterWidgetState();
}

class _OpponentDraggedLetterWidgetState extends State<OpponentDraggedLetterWidget> {
  final GameSyncService _gameSyncService = GetIt.I.get<GameSyncService>();

  OpponentDraggedLetter? _opponentDraggedLetter;

  late StreamSubscription<OpponentDraggedLetter?> oppDragLetterSub;

  @override
  void initState() {
    super.initState();
    oppDragLetterSub = _gameSyncService.notifyNewDraggedLetter.stream.listen((event) {
      setState(() {
        _opponentDraggedLetter = event;
      });
    });
  }

  @override
  void dispose() {
    oppDragLetterSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double slotSize =
        min(MediaQuery.of(context).size.height, MediaQuery.of(context).size.width) * 0.055;

    if (_opponentDraggedLetter != null) {
      return Positioned(
          top: _opponentDraggedLetter!.coord.y.toDouble(),
          left: _opponentDraggedLetter!.coord.x.toDouble(),
          child: LetterWidget(
              character: _opponentDraggedLetter!.letter.character,
              points: _opponentDraggedLetter!.letter.points,
              widgetSize: slotSize));
    } else {
      return const SizedBox.shrink();
    }
  }
}
