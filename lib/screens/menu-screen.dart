import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/screens/chat-screen.dart';
import 'package:mobile/domain/services/chat-service.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key, required this.title});

  final String title;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/scrabble_logo.png", width: 500),
            const SizedBox(height: 100),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: 300,
                      child: Form(
                        child: TextFormField(
                          onFieldSubmitted: (String msg) {
                            // submitMessage(msgController.text);
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Ecrivez votre nom d'utilisateur ici",
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green), onPressed: () {}, child: Text("Sign in")),
                    const SizedBox(height: 5),
                    ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () {}, child: Text("Log out")),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: false
                    ? null
                    : () {
                        GetIt.I<ChatService>().joinRoom("Gary Anderson");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ChatScreen(
                                  title: "Prototype: Salle de clavarage")),
                        );
                      },
                child: Text("Rejoindre une salle de clavardage")),
          ],
        ),
      ),
    );
  }
}
