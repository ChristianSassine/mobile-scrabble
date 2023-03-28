import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/models/room-model.dart';
import 'package:mobile/domain/services/game-service.dart';
import 'package:mobile/domain/services/room-service.dart';

import 'game-screen.dart';

class WaitingRoomScreen extends StatefulWidget {
  const WaitingRoomScreen({Key? key}) : super(key: key);

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomState();
}

class _WaitingRoomState extends State<WaitingRoomScreen> {
  final _roomService = GetIt.I.get<RoomService>();
  late final StreamSubscription newMemberSub;

  // late final StreamSubscription kickedOutSub;

  late GameRoom currentRoom;
  final ScrollController _scrollController = ScrollController();

  @override
  initState() {
    super.initState();

    newMemberSub =
        _roomService.notifyRoomMemberList.stream.listen((newRoomState) {
      if (newRoomState == null) {
        // Exit waiting room (From kick or host closed the)
        Navigator.pop(context);
        return;
      }
      setState(() {});
    });
  }

  _startGame() {
    _roomService.startScrabbleGame();
  }

  Widget _buildRoomMemberCard(String playerName) {
    return Card(
      child: ListTile(
        title: Text(playerName),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    newMemberSub.cancel();

    if (!GetIt.I.get<GameService>().inGame) {
      _roomService.exitRoom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Text(FlutterI18n.translate(context, "waiting_room.screen_name"))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text(_roomService.currentRoom., style: const TextStyle(fontSize: 50)),
            const SizedBox(height: 100),
            Text(FlutterI18n.translate(context, "waiting_room.players"),
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            SizedBox(
              width: 500,
              height: 300,
              child: Card(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.white70, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Scrollbar(
                  child: ListView(
                    controller: _scrollController,
                    children: [
                      for (RoomPlayer playerName
                          in _roomService.currentRoom!.players)
                        _buildRoomMemberCard(playerName.user.username)
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startGame,
        tooltip: FlutterI18n.translate(context, "waiting_room.start_game"),
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
