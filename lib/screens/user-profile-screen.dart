import 'package:flutter/material.dart';
import 'package:mobile/screens/user-settings-screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("User profile"),
      ),
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: IntrinsicWidth(
              child: Column(
                children: [
                  Text("JohnScrabble", style: theme.textTheme.titleLarge),
                  CircleAvatar(
                    radius: size.height * 0.05,
                    child: Icon(Icons.person), // TODO : replace with real image
                  ),
                  RichText(
                      text: TextSpan(children: [
                    TextSpan(
                        text: "Score : ", style: theme.textTheme.titleMedium),
                    TextSpan(
                        text: "49992",
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold))
                  ])),
                  OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const UserSettingsScreen()));
                      },
                      child: Text("Settings")),
                  Divider(),
                  Row(
                    children: [
                      Container(
                        width: size.width * 0.2,
                        height: size.height * 0.5,
                        color: Colors.green,
                      ),
                      const VerticalDivider(),
                      Container(
                          width: size.width * 0.2,
                          height: size.height * 0.5,
                          color: Colors.red),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
