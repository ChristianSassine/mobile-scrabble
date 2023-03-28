import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/models/room-model.dart';
import 'package:mobile/domain/services/auth-service.dart';
import 'package:mobile/screens/waiting-room-screen.dart';
import '../domain/services/room-service.dart';

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

  // Form objects
  final _formKey = GlobalKey<FormState>();
  final List<bool> _selectedVisibility = <bool>[true, false];
  final TextEditingController _roomNameFieldController = TextEditingController();

  List<Widget> _getGameVisibilities() {
    return <Widget>[
      Text(FlutterI18n.translate(context, "form.private")),
      Text(FlutterI18n.translate(context, "form.public"))
    ];
  }

  void _chooseVisibility(index) {
    setState(() {
      // The button that is tapped is set to true, and the others to false.
      for (int i = 0; i < _selectedVisibility.length; i++) {
        _selectedVisibility[i] = i == index;
      }
    });
  }

  String? _validateRoomName(roomName) {
    if (roomName == null || roomName.isEmpty || roomName.trim() == '') {
      return FlutterI18n.translate(context, "form.missing_room_name");
    }
    return null;
  }

  void _createGame() {
    if (_formKey.currentState!.validate()) {
      GameCreationQuery query = GameCreationQuery(
          user: _authService.user!,
          dictionary: "Mon dictionnaire",
          timer: 60,
          gameMode: GameMode.Multi,
          visibility: GameVisibility.Public,
          botDifficulty: GameDifficulty.Easy);
      _roomService.createRoom(query);
      Navigator.push(context, MaterialPageRoute(builder: (context) => const WaitingRoomScreen()));
    }
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
                            TextFormField(
                              validator: _validateRoomName,
                              controller: _roomNameFieldController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: FlutterI18n.translate(context, "form.username_field"),
                              ),
                              onFieldSubmitted: (_) => _createGame(),
                            ),
                            Text(FlutterI18n.translate(context, "form.game_visibility")),
                            const SizedBox(height: 5),
                            ToggleButtons(
                              onPressed: _chooseVisibility,
                              borderRadius: const BorderRadius.all(Radius.circular(8)),
                              selectedBorderColor: Colors.green[700],
                              selectedColor: Colors.white,
                              fillColor: Colors.green[200],
                              color: Colors.green[400],
                              constraints: const BoxConstraints(
                                minHeight: 40.0,
                                minWidth: 80.0,
                              ),
                              isSelected: _selectedVisibility,
                              children: _getGameVisibilities(),
                            ),
                          ],
                        ),
                        //TODO: Add fields for gamemode selection,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _createGame,
                      child: Text(FlutterI18n.translate(context, "form.create_game")),
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
