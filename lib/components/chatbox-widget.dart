import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/services/chatbox-service.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({
    Key? key,
  }) : super(key: key);

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final msgController = TextEditingController();
  final chatboxService = GetIt.I.get<ChatboxService>();

  @override
  Widget build(BuildContext context) {
    return Form(
      child: TextFormField(
        controller: msgController,
        onFieldSubmitted: (String msg) {
          chatboxService.addMessage(msgController.text);
          msgController.clear();
        },
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Write your message here",
            suffixIcon: IconButton(
              onPressed: () {
                chatboxService.addMessage(msgController.text);
                msgController.clear();
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
  final chatboxService = GetIt.I.get<ChatboxService>();
  var messages = [];
  StreamSubscription? sub;

  @override
  Widget build(BuildContext context) {
    // Disgusting implementation
    sub ??= chatboxService.subject.stream.listen((value) {
      setState(() {
        messages = chatboxService.msgs;
        print(messages); // For debugging
      });
    });

    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.white70, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListView(
          children: [
            for (var s in messages)
              Card(
                child: ListTile(
                  leading: Text("ME : "),
                  title: Text(s),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (sub != null) {
      sub!.cancel();
    }
  }
}
