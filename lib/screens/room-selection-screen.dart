import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/models/iuser-model.dart';
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

  // HardCoded since there's no dynamic way to do it (Might need to implement it another way or use a library)
  static const double ROW_HEIGHTS = 75;
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
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.smart_toy),
                Text(
                  "${room.players.where((player) => player.playerType == PlayerType.Bot).length}/4",
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.people),
                Text(
                  "${room.players.where((player) => player.playerType == PlayerType.User).length}/4",
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.preview),
                Text(
                  "${room.players.where((player) => player.playerType == PlayerType.Observer).length}/4",
                ),
              ],
            ),
          ],
        ),
      ),
      DataCell(
        Text(room.players.isNotEmpty
            ? room.players
                .firstWhere((player) => player.isCreator ?? false,
                    orElse: () => RoomPlayer(IUser(username: '?'), room.id))
                .user
                .username
            : "?"),
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
                    dataRowHeight: _RoomListState.ROW_HEIGHTS,
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
