import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/components/chat-button-widget.dart';
import 'package:mobile/components/chat-widget.dart';
import 'package:mobile/domain/classes/snackbar-factory.dart';
import 'package:mobile/domain/models/game-model.dart';
import 'package:mobile/domain/services/avatar-service.dart';
import 'package:mobile/domain/services/game-service.dart';
import 'package:mobile/domain/services/user-service.dart';
import 'package:mobile/screens/menu-screen.dart';

class EndGameScreen extends StatefulWidget {
  const EndGameScreen({super.key, this.winner});

  final GameWinner? winner;

  @override
  State<EndGameScreen> createState() => _EndGameScreenState();
}

class _EndGameScreenState extends State<EndGameScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _gameService = GetIt.I.get<GameService>();
  final _avatarService = GetIt.I.get<AvatarService>();
  final _userService = GetIt.I.get<UserService>();

  String? _username;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.winner != null) {
      if (widget.winner?.type == 'bot') {
        _username = widget.winner!.id;
        _imageUrl = _avatarService.botImageUrl;
        return;
      }
      _gameService.fetchWinnerInfo(widget.winner!).then((info) {
        if (info == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBarFactory.redSnack(
              FlutterI18n.translate(context, "end_game.error")));
          return;
        }
        setState(() {
          _username = info.username;
          _imageUrl = info.imageUrl;
        });
      });
    }
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final gameEnded = widget.winner != null;
    final isVictorius = _userService.user!.id == widget.winner?.id;

    return !gameEnded
        ? Text(
            FlutterI18n.translate(context, "end_game.game_ended"),
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  child: Text(
                    FlutterI18n.translate(
                        context,
                        FlutterI18n.translate(
                            context,
                            isVictorius
                                ? "end_game.victory"
                                : "end_game.defeat")),
                    style: theme.textTheme.displayLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isVictorius ? Colors.green : Colors.red),
                  ),
                ),
                Text(
                  _username == null ? "..." : _username!,
                  style: theme.textTheme.titleMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundImage:
                        (_imageUrl != null) ? NetworkImage(_imageUrl!) : null,
                    radius: 35,
                    child: (_imageUrl != null)
                        ? null
                        : const Icon(CupertinoIcons.profile_circled),
                  ),
                ),
                Text(
                  "Score: ${widget.winner!.score}",
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: const Drawer(child: SideChatWidget()),
      key: _scaffoldKey,
      body: Stack(children: [
        Center(
          child: SingleChildScrollView(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(child: _buildHeader()),
                    SizedBox(
                        width: 250,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                                onPressed: () => Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MenuScreen(
                                            title: FlutterI18n.translate(
                                                context,
                                                "menu_screen.screen_name"))),
                                    (_) => false),
                                child: Text(FlutterI18n.translate(
                                    context, "end_game.return_to_menu")))
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
        ChatButtonWidget(scaffoldKey: _scaffoldKey)
      ]),
    );
  }
}
