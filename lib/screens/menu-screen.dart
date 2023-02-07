import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/screens/chat-screen.dart';
import 'package:mobile/domain/services/chat-service.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/scrabble_logo.png", width: 500),
            const SizedBox(height: 100),
            ElevatedButton(
                onPressed: () {
                  GetIt.I<ChatService>().joinRoom("test-user");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const ChatScreen(title: "Prototype: Salle de clavarage")),
                  );
                },
                child: Text("Rejoindre une salle de clavardage")),
          ],
        ),
      ),
    );
  }
}
