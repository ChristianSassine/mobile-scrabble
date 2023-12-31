import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/components/chat-button-widget.dart';
import 'package:mobile/components/chat-widget.dart';
import 'package:mobile/domain/classes/snackbar-factory.dart';
import 'package:mobile/domain/models/room-model.dart';
import 'package:mobile/domain/models/user-auth-models.dart';
import 'package:mobile/domain/services/room-service.dart';
import 'package:mobile/domain/services/user-service.dart';
import 'package:mobile/screens/game-screen.dart';
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
  final _userService = GetIt.I.get<UserService>();
  List<GameRoom> roomList = [];

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  final _passwordController = TextEditingController();
  final _roomIDController = TextEditingController();

  late final StreamSubscription _newRoomSub;
  late final StreamSubscription _validJoinSub;
  late final StreamSubscription _errorSub;

  // HardCoded since there's no dynamic way to do it (Might need to implement it another way or use a library)
  static const double ROW_HEIGHTS = 75;

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
      if (room!.isPlayerObserver(_userService.user!)) {
        debugPrint("isPlayerObserver");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GameScreen()),
        );
      } else {
        debugPrint("waiting room");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WaitingRoomScreen()),
        );
      }
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

  void _joinRoom(String roomId, [String? password]) {
    _roomService.requestJoinRoom(roomId, password);
  }

  AlertDialog _buildPasswordInput() {
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
    final isGameInProgress = room.state == GameState.Playing;
    final isRoomFull = room.players
            .where((player) => player.playerType == PlayerType.User)
            .length ==
        4;

    return DataRow(cells: [
      DataCell(
        Column(
          children: [
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
      DataCell(
        Text(FlutterI18n.translate(
            context,
            room.state == GameState.Playing
                ? "rooms_lobby.table.in_progress"
                : "rooms_lobby.table.waiting")),
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
        onPressed: isRoomFull && !isGameInProgress
            ? null
            : () => {
                  if (isRoomLocked)
                    {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              _buildPasswordInput()).then((password) {
                        if (!password.isEmpty) _joinRoom(room.id, password);
                      })
                    }
                  else
                    _joinRoom(room.id)
                },
        child: isGameInProgress
            ? const Icon(Icons.remove_red_eye)
            : const Icon(Icons.login),
      )),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final roomsLabels = [
      FlutterI18n.translate(context, "rooms_lobby.table.users"),
      FlutterI18n.translate(context, "rooms_lobby.table.host"),
      FlutterI18n.translate(context, "rooms_lobby.table.state"),
      FlutterI18n.translate(context, "rooms_lobby.table.timer"),
      FlutterI18n.translate(context, "rooms_lobby.table.dictionary"),
      '',
      ''
    ];

    return Scaffold(
      endDrawer: const Drawer(child: SideChatWidget()),
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "menu_screen.join_game")),
        actions: const [SizedBox()],
      ),
      body: Stack(children: [
        Center(
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
                        controller: _roomIDController,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: FlutterI18n.translate(
                              context, "rooms_lobby.id_label"),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.login),
                            onPressed: () {
                              _joinRoom(_roomIDController.text);
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
        ChatButtonWidget(scaffoldKey: _scaffoldKey)
      ]),
    );
  }
}
