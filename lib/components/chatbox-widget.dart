import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/models/chat-models.dart';
import 'package:mobile/domain/services/chatbox-service.dart';
import 'package:intl/intl.dart';

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
  final _formKey = GlobalKey<FormState>();

  void _submitMessage() {
    if (_formKey.currentState!.validate()) {
      chatboxService.submitMessage(msgController.text);
      msgController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: TextFormField(
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
            border: OutlineInputBorder(),
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
  final chatboxService = GetIt.I.get<ChatboxService>();
  List<ChatMessage> messages = [];
  StreamSubscription? sub;

  Widget buildMessage(ChatMessage c) {
    if (c.type == 'client') {
      return Card(
        child: ListTile(
          leading: Text(c.username + ' :'),
          title: Text(c.message),
          trailing: Text('| ' + DateFormat.jms().format(c.timeStamp)),
        ),
      );
    }
    return Card(
      child: ListTile(
        leading: Text(c.username),
        title: Center(child: Text(c.message)),
        trailing: Text('| ' + DateFormat.jms().format(c.timeStamp)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          children: [for (ChatMessage c in messages) buildMessage(c)],
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
