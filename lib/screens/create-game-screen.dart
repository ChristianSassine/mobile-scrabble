import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../domain/services/auth-service.dart';

class GameCreationScreen extends StatefulWidget {
  const GameCreationScreen({super.key, required this.title});

  final String title;

  @override
  State<GameCreationScreen> createState() => _GameCreationScreenState();
}

const List<Widget> gameModes = <Widget>[Text('4 Joueurs')];

const List<Widget> gameVisibilities = <Widget>[
  Text('Privée'),
  Text('Publique')
];

class _GameCreationScreenState extends State<GameCreationScreen> {
  // Form objects
  final _formKey = GlobalKey<FormState>();
  final List<bool> _selectedVisibility = <bool>[true, false];

  void _chooseVisibility(index) {
    setState(() {
      // The button that is tapped is set to true, and the others to false.
      for (int i = 0; i < _selectedVisibility.length; i++) {
        _selectedVisibility[i] = i == index;
      }
    });
  }

  void _createGame() {
    //TODO: Validation?

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
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: 300,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            const Text('Visibilité de la partie: '),
                            const SizedBox(height: 5),
                            ToggleButtons(
                              onPressed: _chooseVisibility,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                              selectedBorderColor: Colors.green[700],
                              selectedColor: Colors.white,
                              fillColor: Colors.green[200],
                              color: Colors.green[400],
                              constraints: const BoxConstraints(
                                minHeight: 40.0,
                                minWidth: 80.0,
                              ),
                              isSelected: _selectedVisibility,
                              children: gameVisibilities,
                            ),
                          ],
                        ),
                        //TODO: Add fields for gamemode selection,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _createGame,
                      child: const Text("Créer la partie"),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
