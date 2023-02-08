import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/services/chat-service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.title});

  final String title;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatService chatService;

  _ChatScreenState() {
    chatService = GetIt.I<ChatService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
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
  final chatService = GetIt.I<ChatService>();

  @override
  Widget build(BuildContext context) {
    return Form(
      child: TextFormField(
        controller: msgController,
        onFieldSubmitted: (String msg) {
          submitMessage(msgController.text);
        },
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Write your message here",
            suffixIcon: IconButton(
              onPressed: () {
                submitMessage(msgController.text);
              },
              icon: Icon(Icons.send),
            )),
      ),
    );
  }

  submitMessage(String text){
    if(text.isEmpty) {
      return;
    }

    chatService.submitMessage(text);
    msgController.clear();
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
  final chatService = GetIt.I<ChatService>();
  var messages = [];
  StreamSubscription? sub;

  @override
  Widget build(BuildContext context) {
    // Disgusting implementation
    sub ??= chatService.chatBox.subject.stream.listen((value) {
        setState(() {
          messages = chatService.chatBox.messages;
        });
      });

    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.white70, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListView(
          children: [
            for (var s in messages)
              Card(
                child: ListTile(
                  leading: Text("${s.username}: "),
                  title: Text(s.message),
                ),
              )
          ],
        ),
      ),
    );
  }
}
