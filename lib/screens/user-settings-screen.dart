import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/components/avatar-selector-widget.dart';
import 'package:mobile/domain/services/auth-service.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({Key? key}) : super(key: key);

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  final _usernameFormKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();

  bool _usernameChangeValid = false;
  bool _avatarChangeValid = false;

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
                        child: Text(
                          "Avatar Change",
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AvatarSelector(
                          onImageChange: (avatar) {},
                          // currentInfo: _authService!.user!.profilePicture!,
                        ),
                      ),
                      ElevatedButton(
                          onPressed: _avatarChangeValid ? () {} : null,
                          child: Text("Submit Change")),
                      Divider(
                        color: theme.primaryColorDark,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Username Change",
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Form(
                            key: _usernameFormKey,
                            onChanged: () {
                              setState(() {
                                _usernameChangeValid =
                                    _usernameFormKey.currentState!.validate();
                              });
                            },
                            child: IntrinsicWidth(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      controller: _usernameController,
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: "New username"),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return FlutterI18n.translate(context,
                                              "user_settings.username_error");
                                        }
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: "Confirm new username"),
                                      validator: (value) {
                                        if (value != _usernameController.text) {
                                          return FlutterI18n.translate(context,
                                              "user_settings.username_confirmation_error");
                                        }
                                      },
                                    ),
                                  )
                                ],
                              ),
                            )),
                      ),
                      ElevatedButton(
                          onPressed: _usernameChangeValid ? () {} : null,
                          child: Text("Submit Change")),
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
