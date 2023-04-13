import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/models/room-model.dart';
import 'package:mobile/domain/models/user-auth-models.dart';
import 'package:mobile/domain/services/avatar-service.dart';
import 'package:mobile/domain/services/chat-service.dart';
import 'package:mobile/domain/services/game-service.dart';
import 'package:mobile/domain/services/room-service.dart';
import 'package:mobile/domain/services/dynamic-link-service.dart';
import 'package:clipboard/clipboard.dart';
import 'package:mobile/domain/services/user-service.dart';

class WaitingRoomScreen extends StatefulWidget {
  const WaitingRoomScreen({Key? key}) : super(key: key);

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomState();
}

class _WaitingRoomState extends State<WaitingRoomScreen> {
  final _roomService = GetIt.I.get<RoomService>();
  final _userService = GetIt.I.get<UserService>();
  final _avatarService = GetIt.I.get<AvatarService>();
  final DynamicLinkService _dynamicLinkService = GetIt.I.get<DynamicLinkService>();
  late final StreamSubscription newMemberSub;

  final ScrollController _scrollController = ScrollController();

  @override
  initState() {
    super.initState();
    newMemberSub = _roomService.notifyRoomMemberList.stream.listen((newRoomState) {
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
          content: Text(FlutterI18n.translate(context, "waiting_room.copy_link_success"))));
    }).catchError((error) => debugPrint('Error copying link to clipboard: $error'));
  }

  _startGame() {
    _roomService.startScrabbleGame();
  }

  _kickPlayer(RoomPlayer player) {
    _roomService.kickPlayerFromWaitingRoom(player);
  }

  Widget _buildRoomMemberCard(RoomPlayer player) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
            backgroundImage: (player.playerType == PlayerType.Bot)
                ? NetworkImage(_avatarService.botImageUrl)
                : player.user.profilePicture?.key != null
                    ? NetworkImage(player.user.profilePicture!.key!)
                    : null,
            child: player.user.profilePicture?.key != null
                ? null
                : const Icon(CupertinoIcons.profile_circled)),
        title: Row(
          children: [
            Text(player.user.username),
            const SizedBox(
              width: 5,
            ),
            if (player.isCreator == true)
              const Image(image: AssetImage("assets/images/crown.png"), width: 14)
          ],
        ),
        trailing: _roomService.currentRoom!.isPlayerCreator(_userService.user!) &&
                !_roomService.currentRoom!.isPlayerCreator(player.user) &&
                player.playerType != PlayerType.Bot
            ? IconButton(onPressed: _kickPlayer(player), icon: const Icon(Icons.output))
            : null,
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
      appBar: AppBar(title: Text(FlutterI18n.translate(context, "waiting_room.screen_name"))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(FlutterI18n.translate(context, "waiting_room.players"),
                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
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
                      for (RoomPlayer player in _roomService.currentRoom!.players)
                        _buildRoomMemberCard(player)
                    ],
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _onCopyLinkPressed,
              child: Text(FlutterI18n.translate(context, "waiting_room.copy_link_button")),
            ),
          ],
        ),
      ),
      floatingActionButton: Visibility(
        visible: _roomService.currentRoom!.isPlayerCreator(_userService.user!),
        child: FloatingActionButton(
          onPressed: _roomService.currentRoom!.containsTwoPlayers() ? _startGame : _startGame,
          backgroundColor:
              _roomService.currentRoom!.containsTwoPlayers() ? Colors.green : Colors.grey,
          tooltip: FlutterI18n.translate(context, "waiting_room.start_game"),
          child: const Icon(Icons.play_arrow),
        ),
      ),
    );
  }
}
