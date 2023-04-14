import 'dart:async';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/components/chat-button-widget.dart';
import 'package:mobile/components/chat-widget.dart';
import 'package:mobile/domain/models/room-model.dart';
import 'package:mobile/domain/services/dynamic-link-service.dart';
import 'package:mobile/domain/services/game-service.dart';
import 'package:mobile/domain/services/room-service.dart';

class WaitingRoomScreen extends StatefulWidget {
  const WaitingRoomScreen({Key? key}) : super(key: key);

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomState();
}

class _WaitingRoomState extends State<WaitingRoomScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _roomService = GetIt.I.get<RoomService>();
  final DynamicLinkService _dynamicLinkService =
      GetIt.I.get<DynamicLinkService>();
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

  Future<String> _getShareLink() async {
    final String link = await _dynamicLinkService.generateDynamicLink(
        _roomService.currentRoom!.id, _roomService.currentRoom!.password);
    debugPrint(link);
    return link;
  }

  Future<void> _onCopyLinkPressed() async {
    final link = await _getShareLink();
    FlutterClipboard.copy(link).then((value) {
      debugPrint('Link copied to clipboard: $link');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(FlutterI18n.translate(
              context, "waiting_room.copy_link_success"))));
    }).catchError(
        (error) => debugPrint('Error copying link to clipboard: $error'));
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

    if (GetIt.I.get<GameService>().game == null) {
      _roomService.exitRoom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(child: SideChatWidget()),
      key: _scaffoldKey,
      appBar: AppBar(
          title:
              Text(FlutterI18n.translate(context, "waiting_room.screen_name"))),
      body: Stack(children: [
        ChatButtonWidget(scaffoldKey: _scaffoldKey),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text(_roomService.currentRoom., style: const TextStyle(fontSize: 50)),
              const SizedBox(height: 100),
              Text(FlutterI18n.translate(context, "waiting_room.players"),
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
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
              ),
              ElevatedButton(
                onPressed: _onCopyLinkPressed,
                child: Text(FlutterI18n.translate(
                    context, "waiting_room.copy_link_button")),
              ),
            ],
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: _startGame,
        tooltip: FlutterI18n.translate(context, "waiting_room.start_game"),
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
