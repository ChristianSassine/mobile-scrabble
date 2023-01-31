import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile/domain/services/chatbox-service.dart';
import 'package:mobile/main.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.title});

  final String title;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Chatbox(),
            TextFormField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Write your message here",
                  suffixIcon: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.send),
                  )
              ),
            )
          ],

        ),
      )
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
  // var chatboxService = serviceLocator.get<ChatboxService>();
  var messages = ["HelloWorld"];
  // // StreamSubscription subscription = Sub();
  // var assigned = false;

  @override
  Widget build(BuildContext context) {
    // Disgusting implementation
    // if (!assigned){
    //   subscription = chatboxService.subject.listen((value) {
    //     setState(() {
    //       messages = chatboxService.chat;
    //     });
    //   });
    //   assigned = true;
    // }

    return Expanded(
      child: Card(
        child: ListView(
          children: [
            for (var s in messages)
            Card(
              child: ListTile(
                leading: Text("ME : "),
                title: Text(s),
              ),
            )
          ],
        ),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.white70, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
