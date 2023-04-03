import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/components/avatar-selector-widget.dart';
import 'package:mobile/domain/classes/snackbar-factory.dart';
import 'package:mobile/domain/models/avatar-data-model.dart';
import 'package:mobile/domain/services/user-service.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({Key? key}) : super(key: key);

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  final _userService = GetIt.I.get<UserService>();

  final _usernameFormKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordFormKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  AvatarData? currentAvatar;

  bool _usernameChangeValid = false;
  bool _passwordChangeValid = false;
  bool _avatarChangeValid = false;

  late final StreamSubscription<bool> _submitStatusSub;

  @override
  void initState() {
    super.initState();
    _submitStatusSub = _userService.notifyChange.stream.listen((success) {
      if (success)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBarFactory.greenSnack("Modification successful"));
      else
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBarFactory.redSnack("Modification unsuccessful"));
    });
  }

  @override
  void dispose() {
    _submitStatusSub.cancel();
    super.dispose();
  }

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
                width: size.width * 0.60,
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Change Avatar",
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AvatarSelector(
                          onImageChange: (avatar) {
                            if (avatar != null) {
                              setState(() {
                                _avatarChangeValid = true;
                                currentAvatar = avatar;
                              });
                            }
                          },
                          currentInfo: _userService.user!.profilePicture,
                        ),
                      ),
                      ElevatedButton(
                          onPressed: _avatarChangeValid
                              ? () {
                                  setState(() {
                                    _avatarChangeValid = false;
                                  });
                                  _userService.changeUserAvatar(currentAvatar!);
                                }
                              : null,
                          child: Text("Submit Change")),
                      Divider(
                        color: theme.primaryColorDark,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IntrinsicHeight(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Form(
                                  key: _usernameFormKey,
                                  onChanged: () {
                                    setState(() {
                                      _usernameChangeValid = _usernameFormKey
                                          .currentState!
                                          .validate();
                                    });
                                  },
                                  child: IntrinsicWidth(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "Change Username",
                                            style: theme.textTheme.titleLarge,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            controller: _usernameController,
                                            decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                hintText: "New username"),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return FlutterI18n.translate(
                                                    context,
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
                                                hintText:
                                                    "Confirm new username"),
                                            validator: (value) {
                                              if (value !=
                                                  _usernameController.text) {
                                                return FlutterI18n.translate(
                                                    context,
                                                    "user_settings.username_confirmation_error");
                                              }
                                            },
                                          ),
                                        ),
                                        ElevatedButton(
                                            onPressed: _usernameChangeValid
                                                ? () async {
                                                  final newUsername = _usernameController.text;
                                                  final String response = await _userService.modifyUsername(newUsername);
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(response),
                                                    ),
                                                  );
                                                }
                                                : null,
                                            child: Text("Submit Change")),
                                      ],
                                    ),
                                  )),
                              VerticalDivider(),
                              Form(
                                  key: _passwordFormKey,
                                  onChanged: () {
                                    setState(() {
                                      _passwordChangeValid = _passwordFormKey
                                          .currentState!
                                          .validate();
                                    });
                                  },
                                  child: IntrinsicWidth(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "Change Password",
                                            style: theme.textTheme.titleLarge,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            controller: _passwordController,
                                            decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                hintText: "New password"),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return FlutterI18n.translate(
                                                    context,
                                                    "user_settings.password_error");
                                              }
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                hintText:
                                                    "Confirm new password"),
                                            validator: (value) {
                                              if (value !=
                                                  _passwordController.text) {
                                                return FlutterI18n.translate(
                                                    context,
                                                    "user_settings.password_confirmation_error");
                                              }
                                            },
                                          ),
                                        ),
                                        ElevatedButton(
                                            onPressed: _passwordChangeValid
                                                ? () {}
                                                : null,
                                            child: Text("Submit Change")),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
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
