import 'package:flutter/material.dart';

class ChatRoomWidget extends StatefulWidget {
  const ChatRoomWidget({Key? key}) : super(key: key);

  @override
  State<ChatRoomWidget> createState() => _ChatRoomWidgetState();
}

class _ChatRoomWidgetState extends State<ChatRoomWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        color: Colors.green,
      ),
    );
  }
}
