import 'dart:async';

import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/classes/snackbar-factory.dart';
import 'package:mobile/domain/models/chat-models.dart';
import 'package:mobile/domain/services/chat-service.dart';
import 'package:mobile/domain/services/user-service.dart';

// TODO: Adapt whole widget
class ChatRoomWidget extends StatefulWidget {
  const ChatRoomWidget({super.key, required this.scaffoldMessagerKey});

  final GlobalKey<ScaffoldMessengerState> scaffoldMessagerKey;

  @override
  State<ChatRoomWidget> createState() => _ChatRoomWidgetState();
}

class _ChatRoomWidgetState extends State<ChatRoomWidget> {
  // Services
  final _chatService = GetIt.I.get<ChatService>();

  // Tools
  final GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();

  // Subscriptions
  late final StreamSubscription _kickedOutSub;
  late final StreamSubscription _updateNotifsSub;

  @override
  void initState() {
    super.initState();
    if (!_chatService.inRoom) _chatService.onInRoom();

    _kickedOutSub = _chatService.notifyKickedOut.stream.listen((event) {
      widget.scaffoldMessagerKey.currentState?.showSnackBar(
          SnackBarFactory.redSnack(
              FlutterI18n.translate(context, "chat.room_actions.kicked")));
      Navigator.of(context).pop();
    });

    _updateNotifsSub =
        _chatService.notifyUpdatedNotifications.stream.listen((event) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    if (_chatService.inRoom) _chatService.onClosingRoom();
    _updateNotifsSub.cancel();
    _kickedOutSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final room = _chatService.currentRoom!;
    final theme = Theme.of(context);

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: _chatService.notifsCount > 0
                ? badges.Badge(
                    badgeContent: Text("${_chatService.notifsCount}"),
                    child: Icon(Icons.arrow_back),
                  )
                : Icon(Icons.arrow_back),
            onPressed: () {
              _chatService.quitRoom();
              Navigator.of(context).pop();
            },
          ),
          title: Text(room.name),
          actions: [
            if (room.isDeletable)
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError),
                  onPressed: () {
                    _chatService.requestLeaveRoom(room.name);
                    Navigator.of(context).pop();
                  },
                  child: _chatService.isRoomOwner()
                      ? Text(
                          FlutterI18n.translate(context, "chat.delete_label"))
                      : Text(
                          FlutterI18n.translate(context, "chat.leave_label")))
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Chatbox(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.0),
                child: ChatInput(),
              )
            ],
          ),
        ));
  }
}

class ChatInput extends StatefulWidget {
  const ChatInput({
    Key? key,
  }) : super(key: key);

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final msgController = TextEditingController();
  final _chatService = GetIt.I.get<ChatService>();
  final _formKey = GlobalKey<FormState>();

  void _submitMessage() {
    if (_formKey.currentState!.validate()) {
      _chatService.submitMessage(msgController.text);
      msgController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: TextFormField(
        onEditingComplete: () {},
        validator: (value) {
          if (value == null || value.isEmpty || value.trim() == '') {
            return FlutterI18n.translate(context, "chat.chatbox.input_error");
          }
          return null;
        },
        controller: msgController,
        onFieldSubmitted: (String _) {
          _submitMessage();
        },
        decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: FlutterI18n.translate(context, "chat.chatbox.input_hint"),
            suffixIcon: IconButton(
              onPressed: () {
                _submitMessage();
              },
              icon: const Icon(Icons.send),
            )),
      ),
    );
  }
}

class Chatbox extends StatefulWidget {
  const Chatbox({
    Key? key,
  }) : super(key: key);

  @override
  State<Chatbox> createState() => _ChatboxState();
}

class _ChatboxState extends State<Chatbox> {
  final _chatService = GetIt.I.get<ChatService>();
  final _userService = GetIt.I.get<UserService>();
  late final StreamSubscription chatSub;
  List<ChatMessage> messages = [];

  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    messages = _chatService.messages;
    _scrollToBottom();

    chatSub = _chatService.notifyUpdateMessages.stream.listen((value) {
      setState(() {
        messages = _chatService.messages;
      });
      _scrollToBottom();
    });
  }

  Widget _buildMessage(ChatMessage message) {
    // if (message.type == MessageType.CLIENT.value) {
    //   return Card(
    //     color: _userService.user!.username == message.username
    //         ? Colors.white
    //         : Colors.lightGreen,
    //     child: ListTile(
    //       leading: Text("${message.username}: ",
    //           style: const TextStyle(fontWeight: FontWeight.bold)),
    //       title: Text(message.message),
    //       trailing: Text("| ${message.timeStamp}"),
    //     ),
    //   );
    // }
    // if (message.type == MessageType.CLIENT.value) {
    //   return Card(
    //     child: ListTile(
    //       leading: Text("${message.username}: "),
    //       title: Text(message.message),
    //       trailing: Text("| ${message.timeStamp}"),
    //     ),
    //   );
    // }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Card(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              child: Row(
                children: _userService.user?.id == message.userId
                    ? [
                        Flexible(child: Text(message.date)),
                        Flexible(child: Text(message.userId)),
                        CircleAvatar(
                          child: Icon(Icons.person),
                        )
                      ]
                    : [
                        CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        Flexible(child: Text(message.userId)),
                        Flexible(child: Text(message.date))
                      ],
              ),
            ),
            Divider(),
            Container(
              width: double.infinity,
              child: Text(message.message),
            )
          ],
        ),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.white70, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Scrollbar(
          child: ListView(
            controller: _scrollController,
            children: [
              for (ChatMessage message in messages) _buildMessage(message)
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    chatSub.cancel();
    super.dispose();
  }
}
