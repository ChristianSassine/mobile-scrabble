import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/components/chatbox-widget.dart';
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
