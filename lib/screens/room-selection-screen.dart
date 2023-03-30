import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/classes/snackbar-factory.dart';
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
  final _passwordController = TextEditingController();

  late final StreamSubscription _newRoomSub;
  late final StreamSubscription _validJoinSub;
  late final StreamSubscription _errorSub;

  // HardCoded since there's no dynamic way to do it (Might need to implement it another way or use a library)
  static const double ROW_HEIGHTS = 75;
  final roomsLabels = [
    'Joueurs',
    'Hote',
    'Difficulté',
    'Minuterie',
    'Dictionnaire',
    '',
    ''
  ];

  @override
  initState() {
    super.initState();

    _newRoomSub = _roomService.notifyNewRoomList.stream.listen((newRoomList) {
      setState(() {
        roomList = newRoomList;
        debugPrint("roomsUpdated");
      });
    });

    _validJoinSub = _roomService.notifyRoomJoin.stream.listen((room) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WaitingRoomScreen()),
      );
    });

    _errorSub = _roomService.notifyError.stream.listen((errorKey) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBarFactory.redSnack(FlutterI18n.translate(context, errorKey)));
    });
    _roomService.connectToRooms();
  }

  @override
  dispose() {
    _newRoomSub.cancel();
    _validJoinSub.cancel();
    _errorSub.cancel();
    super.dispose();
  }

  _RoomListState() {
    roomList = _roomService.roomList;
  }

  void _joinRoom(GameRoom room, [String? password]) {
    _roomService.requestJoinRoom(room, password);
  }

  AlertDialog _buildPasswordInput() {
    // TODO: Translate + Check if password is not empty (maybe)?
    return AlertDialog(
      title: Text(FlutterI18n.translate(context, "rooms_lobby.password.title")),
      content: TextFormField(
        controller: _passwordController,
        decoration: InputDecoration(
          hintText:
              FlutterI18n.translate(context, "rooms_lobby.password.label"),
          suffixIcon: IconButton(
            icon: const Icon(Icons.login),
            onPressed: () {
              Navigator.of(context).pop(_passwordController.text);
              _passwordController.clear();
            },
          ),
        ),
      ),
    );
  }

  DataRow _buildRoomListing(GameRoom room) {
    final isRoomLocked = room.visibility == GameVisibility.Locked;

    return DataRow(cells: [
      DataCell(
        Column(
          children: [
            // TODO: Refactor rows
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.smart_toy),
                Text(
                  "${room.players.where((player) => player.playerType == PlayerType.Bot).length}",
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
                  "${room.players.where((player) => player.playerType == PlayerType.Observer).length}",
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
        isRoomLocked
            ? Icon(
                Icons.lock,
                color: Theme.of(context).hintColor,
              )
            : const SizedBox(),
      ),
      DataCell(OutlinedButton(
        onPressed: () => {
          if (isRoomLocked)
            {
              showDialog(
                      context: context,
                      builder: (BuildContext context) => _buildPasswordInput())
                  .then((password) {
                if (!password.isEmpty) _joinRoom(room, password);
              })
            }
          else
            _joinRoom(room)
        },
        child: const Icon(Icons.login),
      )),
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
          child: IntrinsicHeight(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.vertical,
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
                ),
                IntrinsicWidth(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText:
                        "Enter Room ID",
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.login),
                          onPressed: () {
                          },
                        ),
                      ),
                    ),
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
