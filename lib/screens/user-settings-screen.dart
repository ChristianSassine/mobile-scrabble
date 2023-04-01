import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/components/avatar-selector-widget.dart';
import 'package:mobile/domain/services/auth-service.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({Key? key}) : super(key: key);

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  final _authService = GetIt.I.get<AuthService>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("User settings"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: size.width * 0.35,
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Avatar Change", style: theme.textTheme.titleLarge,),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AvatarSelector(onImageChange: (avatar){},
                          // currentInfo: _authService!.user!.profilePicture!,
                        ),
                      ),
                      ElevatedButton(onPressed: (){}, child: Text("Submit Change")),
                      Divider(color: theme.primaryColorDark,),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Username Change", style: theme.textTheme.titleLarge,),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(child: IntrinsicWidth(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                      hintText: "New username"
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    hintText: "Confirm new username"
                                  ),
                                ),
                              )
                            ],
                          ),
                        )),
                      ),
                      ElevatedButton(onPressed: (){}, child: Text("Submit Change")),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
