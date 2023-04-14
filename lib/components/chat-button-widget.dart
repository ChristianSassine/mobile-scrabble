import 'dart:async';

import 'package:badges/badges.dart' as badges;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/services/chat-service.dart';

class ChatButtonWidget extends StatefulWidget {
  const ChatButtonWidget({
    super.key,
    required GlobalKey<ScaffoldState> scaffoldKey,
  }) : _scaffoldKey = scaffoldKey;

  final GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  State<ChatButtonWidget> createState() => _ChatButtonWidgetState();
}

class _ChatButtonWidgetState extends State<ChatButtonWidget> {
  final _chatService = GetIt.I.get<ChatService>();
  late final StreamSubscription _updateNotifsSub;

  @override
  void initState() {
    super.initState();
    _updateNotifsSub =
        _chatService.notifyUpdatedNotifications.stream.listen((event) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _updateNotifsSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    return Positioned(
      top: size.height * 0.1,
      right: 0,
      child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(100),
              bottomLeft: Radius.circular(100),
            ),
            color: theme.colorScheme.background,
          ),
          child: IconButton(
              onPressed: () =>
                  widget._scaffoldKey.currentState!.openEndDrawer(),
              icon: _chatService.notifsCount > 0
                  ? badges.Badge(
                      badgeContent: Text("${_chatService.notifsCount}"),
                      position: badges.BadgePosition.topEnd(),
                      child: const Icon(CupertinoIcons.chat_bubble))
                  : const Icon(CupertinoIcons.chat_bubble))),
    );
  }
}
