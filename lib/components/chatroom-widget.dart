import 'dart:async';

import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/models/chat-models.dart';
import 'package:mobile/domain/services/chat-service.dart';
import 'package:mobile/domain/services/user-service.dart';

// TODO: Translate and adapt whole widget
class ChatRoomWidget extends StatefulWidget {
  const ChatRoomWidget({super.key});

  @override
  State<ChatRoomWidget> createState() => _ChatRoomWidgetState();
}

class _ChatRoomWidgetState extends State<ChatRoomWidget> {
  final _chatService = GetIt.I.get<ChatService>();

  @override
  void initState() {
    super.initState();
    if(!_chatService.inRoom) _chatService.signalInRoom();
  }

  @override
  void dispose() {
    _chatService.signalClosingRoom();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const badges.Badge(
              badgeContent: Text('1'),
              child: Icon(Icons.arrow_back),
            ),
            onPressed: () {
              _chatService.quitRoom();
              Navigator.of(context).pop();
            },
          ),
          title: Text(_chatService.currentRoom!.name),
          actions: [ElevatedButton(onPressed: () {}, child: Text('LEAVE'))],
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
            return 'Entrez quelque chose avant de soumettre'; // TODO: Translate
          }
          return null;
        },
        controller: msgController,
        onFieldSubmitted: (String _) {
          _submitMessage();
        },
        decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: "Write your message here",
            suffixIcon: IconButton(
              onPressed: () {
                _submitMessage();
              },
              icon: Icon(Icons.send),
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
    SchedulerBinding.instance.addPostFrameCallback((_) {
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
    return Card(
      child: ListTile(
        leading: Text("test"),
        subtitle: Center(child: Text(message.message)),
        trailing: Text(message.date),
      ),
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
