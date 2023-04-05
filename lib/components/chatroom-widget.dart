import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/models/chat-models.dart';
import 'package:mobile/domain/services/auth-service.dart';
import 'package:mobile/domain/services/chat-service.dart';

class ChatRoomWidget extends StatelessWidget {
  const ChatRoomWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [ElevatedButton(onPressed: () {}, child: Text('LEAVE'))],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[Chatbox(), ChatInput()],
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
            return 'Entrez quelque chose avant de soumettre';
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
  final _authService = GetIt.I.get<AuthService>();
  List<ChatMessage> messages = [];
  final ScrollController _scrollController = ScrollController();
  late final StreamSubscription chatSub;

  @override
  void initState() {
    super.initState();
    chatSub = _chatService.chatBox.subject.stream.listen((value) {
      setState(() {
        messages = _chatService.chatBox.messages;
      });
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      });
    });
  }

  Widget _buildMessage(ChatMessage message) {
    if (message.type == MessageType.CLIENT.value) {
      return Card(
        color: _authService.user!.username == message.username
            ? Colors.white
            : Colors.lightGreen,
        child: ListTile(
          leading: Text("${message.username}: ",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          title: Text(message.message),
          trailing: Text("| ${message.timeStamp}"),
        ),
      );
    }
    if (message.type == MessageType.CLIENT.value) {
      return Card(
        child: ListTile(
          leading: Text("${message.username}: "),
          title: Text(message.message),
          trailing: Text("| ${message.timeStamp}"),
        ),
      );
    }
    return Card(
      child: ListTile(
        leading: Text(message.username),
        title: Center(child: Text(message.message)),
        trailing: Text(message.timeStamp),
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
