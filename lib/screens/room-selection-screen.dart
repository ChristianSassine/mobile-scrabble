import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/models/room-model.dart';
import 'package:mobile/domain/services/room-service.dart';
import 'package:mobile/screens/waiting-room-screen.dart';

class RoomSelectionScreen extends StatefulWidget {
  final String title;

  const RoomSelectionScreen(
    this.title, {
    Key? key,
  }) : super(key: key);

  @override
  State<RoomSelectionScreen> createState() => _RoomListState();
}

class _RoomListState extends State<RoomSelectionScreen> {
  final _roomService = GetIt.I.get<RoomService>();
  List<Room> roomList = [];
  final ScrollController _scrollController = ScrollController();
  StreamSubscription? sub;

  _RoomListState() {
    roomList = _roomService.roomList;
  }

  void _joinRoom(Room room) {
    _roomService.joinRoom(room);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const WaitingRoomScreen("Salle d'attente")),
    );
  }

  Widget _buildRoomCard(Room room) {
    return Card(
      child: ListTile(
        title: Text(room.name),
        trailing: IconButton(
            icon: const Icon(Icons.login),
            color: Colors.green,
            onPressed: () => _joinRoom(room)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    sub ??= _roomService.notifyNewRoomList.stream.listen((newRoomList) {
      setState(() {
        roomList = newRoomList;
      });
    });

    return Scaffold(
      appBar: AppBar(title: Text("Rejoindre une partie")),
      body: Center(
        child: SizedBox(
          width: 500,
          child: Card(
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.white70, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Scrollbar(
              child: ListView(
                controller: _scrollController,
                children: [for (Room room in roomList) _buildRoomCard(room)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
