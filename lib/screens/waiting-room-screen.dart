import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/models/room-model.dart';
import 'package:mobile/domain/services/room-service.dart';

class WaitingRoomScreen extends StatefulWidget {
  final String title;

  const WaitingRoomScreen(
    this.title, {
    Key? key,
  }) : super(key: key);

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomState();
}

class _WaitingRoomState extends State<WaitingRoomScreen> {
  final _roomService = GetIt.I.get<RoomService>();
  late Room currentRoom;
  final ScrollController _scrollController = ScrollController();
  StreamSubscription? sub;

  _WaitingRoomState() {
    currentRoom = _roomService.selectedRoom!;
  }

  _startGame() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //       builder: (context) =>
    //       const GameScreen("Partie")),
    // );
  }

  Widget _buildRoomMemberCard(String playerName) {
    return Card(
      child: ListTile(
        title: Text(playerName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    sub ??= _roomService.notifyRoomMemberList.stream.listen((newRoomState) {
      setState(() {
        currentRoom = newRoomState;
      });
    });

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(currentRoom.name, style: const TextStyle(fontSize: 50)),
          const SizedBox(height: 100),
          const Text("Joueurs", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
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
                    for (String playerName in currentRoom.playerList)
                      _buildRoomMemberCard(playerName)
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startGame,
        tooltip: 'Démarer la partie',
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}
