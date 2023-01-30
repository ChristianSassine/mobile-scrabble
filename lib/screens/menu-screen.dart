import 'package:flutter/material.dart';
import 'package:mobile/screens/chat-screen.dart';

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const ChatScreen(title: "Chat rooms")),
                  );
                },
                child: Text("Rejoindre une salle de clavardage")),
          ],
        ),
      ),
    );
  }
}
