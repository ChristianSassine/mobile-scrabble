import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/components/chat-button-widget.dart';
import 'package:mobile/components/chat-widget.dart';
import 'package:mobile/components/high-scores-widget.dart';
import 'package:mobile/components/language-dropdown-widget.dart';
import 'package:mobile/components/settings-widget.dart';
import 'package:mobile/domain/services/auth-service.dart';
import 'package:mobile/domain/services/user-service.dart';
import 'package:mobile/screens/create-game-screen.dart';
import 'package:mobile/screens/login-screen.dart';
import 'package:mobile/screens/room-selection-screen.dart';
import 'package:mobile/screens/user-profile-screen.dart';

enum DropDownOption {
  UserSettings("userSettings"),
  ThemeSettings("themeSettings"),
  Disconnect("diconnect");

  const DropDownOption(this.value);

  final String value;
}

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key, required this.title});

  final String title;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var loggedIn = false;

  final _authService = GetIt.I.get<AuthService>();
  final _userService = GetIt.I.get<UserService>();

  _handleOption(DropDownOption option) {
    switch (option) {
      case DropDownOption.ThemeSettings:
        {
          showModalBottomSheet(
              context: context,
              builder: (BuildContext context) =>
                  Settings(notifyParent: () => setState(() {})));
        }
        break;
      case DropDownOption.UserSettings:
        {
          Navigator.of(context)
              .push(MaterialPageRoute(
                  builder: (context) => const UserProfileScreen()))
              .then((value) {
            setState(() {});
          });
        }
        break;
      case DropDownOption.Disconnect:
        _authService.disconnect();
        {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => LoginScreen(
                      title: FlutterI18n.translate(
                          context, "menu_screen.login_screen"))),
              (route) => false);
        }
        break;
      default:
        {}
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final imageUrl = _userService.user?.profilePicture?.key;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(
          "assets/images/scrabble_logo.png",
          fit: BoxFit.contain,
          height: 32, // Size that makes the image fit
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PopupMenuButton<DropDownOption>(
                onSelected: (DropDownOption option) {
                  _handleOption(option);
                },
                offset: const Offset(0, kTextTabBarHeight),
                icon: CircleAvatar(
                    backgroundImage:
                        imageUrl != null ? NetworkImage(imageUrl) : null,
                    child: imageUrl != null
                        ? null
                        : const Icon(CupertinoIcons.profile_circled)),
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem(
                        value: DropDownOption.UserSettings,
                        child: Center(
                            child: Text(FlutterI18n.translate(
                                context, "menu_screen.settings.user")))),
                    PopupMenuItem(
                        value: DropDownOption.ThemeSettings,
                        child: Center(
                            child: Text(FlutterI18n.translate(
                                context, "menu_screen.settings.theme")))),
                    PopupMenuItem(
                        value: DropDownOption.Disconnect,
                        child: Center(
                            child: Text(FlutterI18n.translate(
                                context, "menu_screen.settings.disconnect")))),
                  ];
                }),
          )
        ],
      ),
      bottomSheet: Footer(
        size: size,
        notifyParent: () => setState(() {}),
      ),
      endDrawer: const Drawer(
        child: SideChatWidget(),
      ),
      body: Stack(children: [
        ChatButtonWidget(scaffoldKey: _scaffoldKey),
        Center(
          child: SingleChildScrollView(
            child: Card(
                child: Padding(
                    padding: const EdgeInsets.only(
                        left: 30.0, right: 30, bottom: 15, top: 15),
                    child: Column(children: [
                      ElevatedButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GameCreationScreen(
                                      title: FlutterI18n.translate(context,
                                          "menu_screen.create_game")))),
                          child: Text(FlutterI18n.translate(
                              context, "menu_screen.create_game"))),
                      ElevatedButton(
                        onPressed: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RoomSelectionScreen(),
                            ),
                          )
                        },
                        child: Text(FlutterI18n.translate(
                            context, "menu_screen.join_game")),
                      ),
                      SizedBox(
                        height: size.height * 0.05,
                      ),
                      ElevatedButton(
                        onPressed: () => {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => Dialog(
                                    child: HighScores(),
                                  ))
                        },
                        child: Text(FlutterI18n.translate(
                            context, "menu_screen.score")),
                      ),
                    ]))),
          ),
        ),
      ]),
    );
  }
}

class Footer extends StatefulWidget {
  const Footer({Key? key, required this.size, required this.notifyParent})
      : super(key: key);

  final Size size;
  final Function() notifyParent;

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  final _maintainers = [
    "Christian Sassine",
    "Raphael Tremblay",
    "Laurent Nguyen",
    "Yasser Kadimi",
    "Esmé Généreux",
    "Michael Russel"
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: widget.size.height * 0.1,
      color: theme.backgroundColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: const [
                    Icon(Icons.language),
                    LanguageDropdown(),
                  ],
                ),
              )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _maintainers
                .map((e) => TextButton(onPressed: () {}, child: Text(e)))
                .toList(),
          ),
        ],
      ),
    );
  }
}
