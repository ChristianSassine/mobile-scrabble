import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/components/toggle-icon-button.dart';
import 'package:mobile/components/dropdown-menu.dart' as menu;
import 'package:mobile/domain/models/room-model.dart';
import 'package:mobile/domain/services/dictionary-service.dart';
import 'package:mobile/domain/services/room-service.dart';
import 'package:mobile/domain/services/user-service.dart';
import 'package:mobile/screens/waiting-room-screen.dart';

class GameCreationScreen extends StatefulWidget {
  const GameCreationScreen({super.key, required this.title});

  final String title;

  @override
  State<GameCreationScreen> createState() => _GameCreationScreenState();
}

class _GameCreationScreenState extends State<GameCreationScreen> {
  final _userService = GetIt.I.get<UserService>();
  final _roomService = GetIt.I.get<RoomService>();
  final _dictionaryService = GetIt.I.get<DictionaryService>();

  late final StreamSubscription _newDictionariesSub;

  // Form objects
  final _formKey = GlobalKey<FormState>();
  final _roomPasswordController = TextEditingController();

  bool _isPublic = true;
  bool _isProtected = false;

  GameDifficulty _selectedDifficulty = GameDifficulty.Easy;
  int _selectedTimer = 60;
  String? _selectedDictionary;

  bool _formValid = true;

  _GameCreationScreenState() {
    _dictionaryService.fetchDictionaries();
  }

  void _createGame() {
    if (_formKey.currentState!.validate()) {
      GameCreationQuery query = GameCreationQuery(
          user: _userService.user!,
          dictionary: _selectedDictionary!,
          timer: _selectedTimer,
          gameMode: GameMode.Multi,
          visibility: _isPublic
              ? (_isProtected ? GameVisibility.Locked : GameVisibility.Public)
              : GameVisibility.Private,
          botDifficulty: _selectedDifficulty,
          password: _isProtected ? _roomPasswordController.text : null);
      _roomService.createRoom(query);
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const WaitingRoomScreen()));
    }
  }

  @override
  void initState() {
    super.initState();
    _newDictionariesSub =
        _dictionaryService.notifyNewDictionaries.stream.listen((_) {
      setState(() {
        _selectedDictionary = _dictionaryService.dictionaries.isNotEmpty
            ? _dictionaryService.dictionaries[0].title
            : null;
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
                            Text(
                                FlutterI18n.translate(
                                    context, "room_create.room_param_title"),
                                style: TextStyle(fontSize: 30)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ToggleIconButton(
                                  off_icon: Icons.lock_outline,
                                  on_icon: Icons.lock_open_outlined,
                                  onChanged: (value) {
                                    setState(() {
                                      _isProtected = value;
                                      _formValid = !_isProtected ||
                                          _roomPasswordController
                                              .text.isNotEmpty;
                                    });
                                  },
                                ),
                                ToggleIconButton(
                                  off_icon: Icons.visibility_off,
                                  on_icon: Icons.visibility,
                                  onChanged: (value) {
                                    _isPublic = value;
                                  },
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 200,
                              child: Column(
                                children: [
                                  Visibility(
                                    visible: _isProtected,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: TextFormField(
                                        controller: _roomPasswordController,
                                        validator: (value) => value == null ||
                                                value.isEmpty
                                            ? FlutterI18n.translate(
                                                context, "form.password_empty")
                                            : null,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: FlutterI18n.translate(
                                              context, "form.password"),
                                          suffixIcon: const Icon(Icons.key),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            _formValid = value.isNotEmpty;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  menu.DropdownMenu(
                                    title:
                                    "${FlutterI18n.translate(context, "room_create.difficulty_field_title")} *",
                                    items: {
                                      FlutterI18n.translate(context, "room_create.difficulty.easy"):
                                      GameDifficulty.Easy.value,
                                      FlutterI18n.translate(context, "room_create.difficulty.hard"):
                                      GameDifficulty.Hard.value,
                                      FlutterI18n.translate(
                                          context, "room_create.difficulty.score_based"):
                                      GameDifficulty.ScoreBased.value,
                                    },
                                    onChanged: (value) {
                                      _selectedDifficulty = GameDifficulty.fromString(value!)!;
                                    },
                                    value: GameDifficulty.Easy.value,
                                  ),
                                  menu.DropdownMenu(
                                    title:
                                        "${FlutterI18n.translate(context, "room_create.timer_field_title")} *",
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
                                      _selectedTimer = int.parse(value!);
                                    },
                                    value: "60",
                                  ),
                                  menu.DropdownMenu(
                                    title:
                                        "${FlutterI18n.translate(context, "room_create.dictionary_field_title")} *",
                                    items: {
                                      for (var item
                                          in _dictionaryService.dictionaries)
                                        item.title: item.title
                                    },
                                    onChanged: (value) {
                                      _selectedDictionary = value;
                                    },
                                    value: _selectedDictionary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        //TODO: Add fields for gamemode selection,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _formValid ? _createGame : null,
                      child: Text(
                        FlutterI18n.translate(context, "form.create_game"),
                        style: TextStyle(fontSize: 18),
                      ),
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
