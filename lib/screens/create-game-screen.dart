import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/components/dropdown-menu.dart';
import 'package:mobile/components/toggle-icon-button.dart';
import 'package:mobile/domain/models/room-model.dart';
import 'package:mobile/domain/services/auth-service.dart';
import 'package:mobile/domain/services/dictionary-service.dart';
import 'package:mobile/screens/waiting-room-screen.dart';
import 'package:mobile/domain/services/room-service.dart';

class GameCreationScreen extends StatefulWidget {
  const GameCreationScreen({super.key, required this.title});

  final String title;

  @override
  State<GameCreationScreen> createState() => _GameCreationScreenState();
}

const List<Widget> gameModes = <Widget>[Text('4 Joueurs')];

class _GameCreationScreenState extends State<GameCreationScreen> {
  final _authService = GetIt.I.get<AuthService>();
  final _roomService = GetIt.I.get<RoomService>();
  final _dictionaryService = GetIt.I.get<DictionaryService>();

  late final StreamSubscription _newDictionariesSub;

  // Form objects
  final _formKey = GlobalKey<FormState>();

  GameDifficulty selectedDifficulty = GameDifficulty.Easy;
  int selectedTimer = 60;
  String? selectedDictionary;

  _GameCreationScreenState() {
    _dictionaryService.fetchDictionaries();
  }

  void _createGame() {
    if (_formKey.currentState!.validate()) {
      GameCreationQuery query = GameCreationQuery(
          user: _authService.user!,
          dictionary: selectedDictionary!,
          timer: selectedTimer,
          gameMode: GameMode.Multi,
          visibility: GameVisibility.Public,
          botDifficulty: selectedDifficulty);
      _roomService.createRoom(query);
      Navigator.push(context, MaterialPageRoute(builder: (context) => const WaitingRoomScreen()));
    }
  }

  @override
  void initState() {
    super.initState();
    _newDictionariesSub = _dictionaryService.notifyNewDictionaries.stream.listen((_) {
      setState(() {
        selectedDictionary = _dictionaryService.dictionaries.isNotEmpty ? _dictionaryService.dictionaries[0].title : null;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _newDictionariesSub.cancel();
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
                            const Text("Paramètres de jeu", style: TextStyle(fontSize: 30)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                ToggleIconButton(
                                  off_icon: Icons.lock_outline,
                                  on_icon: Icons.lock_open_outlined,
                                ),
                                ToggleIconButton(
                                  off_icon: Icons.visibility_off,
                                  on_icon: Icons.visibility,
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 200,
                              child: DropdownMenu(
                                title: "Difficulté *",
                                items: {
                                  "Débutant": GameDifficulty.Easy.value,
                                  "Expert": GameDifficulty.Hard.value,
                                  "Basé sur le score": GameDifficulty.ScoreBased.value,
                                },
                                onChanged: (value) {
                                  selectedDifficulty = GameDifficulty.fromString(value!)!;
                                },
                                defaultValue: GameDifficulty.Easy.value,
                              ),
                            ),
                            SizedBox(
                              width: 200,
                              child: DropdownMenu(
                                title: "Minuterie *",
                                items: const {
                                  "0:30": "30",
                                  "1:00": "60",
                                  "1:30": "90",
                                  "2:00": "120",
                                  "2:30": "150",
                                  "3:00": "180",
                                  "3:30": "210",
                                  "4:00": "240",
                                  "4:30": "270",
                                  "5:00": "300"
                                },
                                onChanged: (value) {
                                  selectedTimer = int.parse(value!);
                                },
                                defaultValue: "60",
                              ),
                            ),
                            SizedBox(
                              width: 200,
                              child: DropdownMenu(
                                title: "Dictionaire *",
                                items: {
                                  for (var item in _dictionaryService.dictionaries)
                                    item.title: item.title
                                },
                                onChanged: (value) {
                                  selectedDictionary = value;
                                },
                                defaultValue: _dictionaryService.dictionaries.isNotEmpty
                                    ? _dictionaryService.dictionaries[0].title
                                    : null,
                              ),
                            )
                          ],
                        ),
                        //TODO: Add fields for gamemode selection,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _createGame,
                      child: Text(FlutterI18n.translate(context, "form.create_game"), style: TextStyle(fontSize: 18),),
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
