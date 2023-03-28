import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/models/room-model.dart';
import 'package:mobile/domain/services/room-service.dart';
import 'package:mobile/screens/waiting-room-screen.dart';

class RoomSelectionScreen extends StatefulWidget {
  const RoomSelectionScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<RoomSelectionScreen> createState() => _RoomListState();
}

class _RoomListState extends State<RoomSelectionScreen> {
  final _roomService = GetIt.I.get<RoomService>();
  List<GameRoom> roomList = [];

  final ScrollController _scrollController = ScrollController();
  late final StreamSubscription newRoomSub;
  late final StreamSubscription validJoinSub;

  final roomsLabels = [
    'Joueurs',
    'Hote',
    'Difficulté',
    'Minuterie',
    'Dictionnaire',
    ''
  ];

  @override
  initState() {
    super.initState();

    newRoomSub = _roomService.notifyNewRoomList.stream.listen((newRoomList) {
      setState(() {
        roomList = newRoomList;
        debugPrint("roomsUpdated");
      });
    });

    validJoinSub = _roomService.notifyRoomJoin.stream.listen((room) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WaitingRoomScreen()),
      );
    });
    _roomService.connectToRooms();
  }

  @override
  dispose() {
    newRoomSub.cancel();
    validJoinSub.cancel();
    super.dispose();
  }

  _RoomListState() {
    roomList = _roomService.roomList;
  }

  void _joinRoom(GameRoom room) {
    _roomService.requestJoinRoom(room);
  }

  DataRow _buildRoomListing(GameRoom room) {
    return DataRow(cells: [
      DataCell(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(Icons.people),
            Text(
              "${room.players.length}/4",
            ),
          ],
        ),
      ),
      DataCell(
        Text(room.players.isNotEmpty ? room.players[0].user.username : "?"),
      ),
      const DataCell(
        Text("HARDCODED"),
      ),
      DataCell(
        Text(room.timer.toString()),
      ),
      DataCell(
        Text(room.dictionary),
      ),
      DataCell(
        IconButton(
            color: Theme.of(context).primaryColor,
            onPressed: () => _joinRoom(room),
            icon: const Icon(Icons.login)),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(FlutterI18n.translate(context, "menu_screen.join_game"))),
      body: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.white70, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DataTable(
                    columns: roomsLabels
                        .map((label) => DataColumn(
                              label: Expanded(
                                child: Text(label),
                              ),
                            ))
                        .toList(),
                    rows: roomList
                        .map((room) => _buildRoomListing(room))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
