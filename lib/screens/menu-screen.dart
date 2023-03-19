import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/components/settings-widget.dart';
import 'package:mobile/domain/services/auth-service.dart';
import 'package:mobile/screens/create-game-screen.dart';
import 'package:mobile/screens/room-selection-screen.dart';

enum DropDownOption {
  UserSettings("userSettings"),
  ThemeSettings("themeSettings");

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
  final authService = GetIt.I.get<AuthService>();
  var loggedIn = false;
  final _maintainers = [
    "Christian Sassine",
    "Raphael Tremblay",
    "Laurent Nguyen",
    "Yasser Kadimi",
    "Esmé Généreux",
    "Michael Russel"
  ];

  _handleOption(DropDownOption option) {
    switch(option) {
      case DropDownOption.ThemeSettings:{
        showModalBottomSheet(
            context: context,
            builder: (BuildContext context) =>
                Settings(notifyParent: () => setState(() {})));
      }
      break;
      case DropDownOption.UserSettings: {
        // TODO: Add user settings
      }
      break;
      default: {}
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;

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
              onSelected: (DropDownOption option){
                _handleOption(option);
              },
                offset: const Offset(0, kTextTabBarHeight),
                icon: const CircleAvatar(
                    child: Icon(CupertinoIcons.profile_circled)
                ),
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem(
                      value: DropDownOption.UserSettings,
                        child: Center(child: Text("User settings"))
                    ),
                    const PopupMenuItem(
                        value: DropDownOption.ThemeSettings,
                        child: Center(child: Text("Theme settings"))
                    ),
                  ];
                }),
          )
        ],
      ),
      bottomSheet: Container(
        height: size.height * 0.1,
        color: Theme
            .of(context)
            .backgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _maintainers
              .map((e) => TextButton(onPressed: () {}, child: Text(e)))
              .toList(),
        ),
      ),
      drawer: const Drawer(
        child: SafeArea(child: Placeholder()),
      ),
      body: Stack(children: [
        Positioned(
          top: size.height * 0.1,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(100),
                bottomRight: Radius.circular(100),
              ),
              color: Theme
                  .of(context)
                  .backgroundColor,
            ),
            child: IconButton(
                onPressed: () => _scaffoldKey.currentState!.openDrawer(),
                icon: const Icon(CupertinoIcons.chat_bubble)),
          ),
        ),
        Center(
          child: SingleChildScrollView(
            child: Card(
                child: Padding(
                    padding: const EdgeInsets.only(
                        left: 30.0, right: 30, bottom: 15, top: 15),
                    child: Column(children: [
                      ElevatedButton(
                          onPressed: () =>
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          GameCreationScreen(
                                              title: FlutterI18n.translate(
                                                  context,
                                                  "menu_screen.create_game")))),
                          child: Text(FlutterI18n.translate(
                              context, "menu_screen.create_game"))),
                      ElevatedButton(
                        onPressed: () =>
                        {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    RoomSelectionScreen(
                                        FlutterI18n.translate(
                                            context, "menu_screen.join_game"))),
                          )
                        },
                        child: Text(FlutterI18n.translate(
                            context, "menu_screen.join_game")),
                      ),
                      SizedBox(
                        height: size.height * 0.05,
                      ),
                      ElevatedButton(
                        onPressed: () => {},
                        child: Text("High Scores"), // TODO: translate
                      ),
                    ]))),
          ),
        ),
      ]),
    );
  }
}
