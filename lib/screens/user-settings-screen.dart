import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/components/avatar-selector-widget.dart';
import 'package:mobile/components/chat-button-widget.dart';
import 'package:mobile/components/chat-widget.dart';
import 'package:mobile/domain/classes/snackbar-factory.dart';
import 'package:mobile/domain/enums/server-events-enum.dart';
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
  final _confirmUsernameController = TextEditingController();
  final _passwordFormKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isUsernameInputReset = false;
  bool _isPasswordInputReset = false;
  AvatarData? currentAvatar;

  bool _usernameChangeValid = false;
  bool _passwordChangeValid = false;
  bool _avatarChangeValid = false;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late final StreamSubscription<bool> _submitStatusSub;

  @override
  void initState() {
    super.initState();
    _submitStatusSub = _userService.notifyChange.stream.listen((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBarFactory.greenSnack(
            FlutterI18n.translate(
                context, 'user_settings.modify_avatar.success')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBarFactory.redSnack(
            FlutterI18n.translate(
                context, 'user_settings.modify_avatar.error')));
      }
    });
  }

  @override
  void dispose() {
    _submitStatusSub.cancel();
    super.dispose();
  }

  void _modifyPassword(String newPassword) async {
    final ServerEvents response =
        await _userService.modifyPassword(newPassword);

    if (response == ServerEvents.PasswordChangeSucess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBarFactory.greenSnack(
          FlutterI18n.translate(
              context, "user_settings.modify_password.success"),
        ),
      );
    } else if (response == ServerEvents.PasswordSameError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBarFactory.redSnack(
          FlutterI18n.translate(
              context, "user_settings.modify_password.already_exists"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBarFactory.redSnack(
          FlutterI18n.translate(context, "user_settings.modify_password.error"),
        ),
      );
    }
  }

  void _modifyUsername(String newUsername) async {
    final ServerEvents response =
        await _userService.modifyUsername(newUsername);

    if (response == ServerEvents.UsernameChangeSucess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBarFactory.greenSnack(
          FlutterI18n.translate(
              context, "user_settings.modify_username.success"),
        ),
      );
    } else if (response == ServerEvents.UsernameExistsError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBarFactory.redSnack(
          FlutterI18n.translate(
              context, "user_settings.modify_username.already_exists"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBarFactory.greenSnack(
          FlutterI18n.translate(context, "user_settings.modify_username.error"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      endDrawer: const Drawer(child: SideChatWidget()),
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(FlutterI18n.translate(
            context, "user_settings.labels.user_settings")),
        actions: const [SizedBox()],
      ),
      body: Stack(children: [
        Center(
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
                            FlutterI18n.translate(
                                context, "user_settings.labels.change_avatar"),
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
                                    _userService
                                        .changeUserAvatar(currentAvatar!);
                                  }
                                : null,
                            child: Text(FlutterI18n.translate(
                                context, "user_settings.submit_button"))),
                        Divider(),
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
                                              FlutterI18n.translate(context,
                                                  "user_settings.labels.change_username"),
                                              style: theme.textTheme.titleLarge,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextFormField(
                                              controller: _usernameController,
                                              decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  hintText: FlutterI18n.translate(
                                                      context,
                                                      "user_settings.modify_username.hint")),
                                              validator: (value) {
                                                if ((value == null ||
                                                        value.isEmpty) &&
                                                    !_isUsernameInputReset) {
                                                  return FlutterI18n.translate(
                                                      context,
                                                      "user_settings.modify_username.input_error_empty");
                                                }
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextFormField(
                                              controller:
                                                  _confirmUsernameController,
                                              decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  hintText: FlutterI18n.translate(
                                                      context,
                                                      "user_settings.modify_username.confirm_username")),
                                              validator: (value) {
                                                if (value !=
                                                    _usernameController.text) {
                                                  return FlutterI18n.translate(
                                                      context,
                                                      "user_settings.modify_username.input_error_match");
                                                }
                                              },
                                            ),
                                          ),
                                          ElevatedButton(
                                              onPressed: _usernameChangeValid
                                                  ? () {
                                                      final newUsername =
                                                          _usernameController
                                                              .text;
                                                      _modifyUsername(
                                                          newUsername);
                                                      setState(() {
                                                        _isUsernameInputReset =
                                                            true;
                                                        _usernameController
                                                            .clear();
                                                        _confirmUsernameController
                                                            .clear();
                                                        _isUsernameInputReset =
                                                            false;
                                                        _usernameChangeValid =
                                                            false;
                                                      });
                                                    }
                                                  : null,
                                              child: Text(FlutterI18n.translate(
                                                  context,
                                                  "user_settings.submit_button"))),
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
                                              FlutterI18n.translate(context,
                                                  "user_settings.labels.change_password"),
                                              style: theme.textTheme.titleLarge,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextFormField(
                                              obscureText: true,
                                              controller: _passwordController,
                                              decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  hintText: FlutterI18n.translate(
                                                      context,
                                                      "user_settings.modify_password.hint")),
                                              validator: (value) {
                                                if ((value == null ||
                                                        value.isEmpty) &&
                                                    !_isPasswordInputReset) {
                                                  return FlutterI18n.translate(
                                                      context,
                                                      "user_settings.modify_password.input_error_empty");
                                                }
                                              },
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: TextFormField(
                                              obscureText: true,
                                              controller:
                                                  _confirmPasswordController,
                                              decoration: InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  hintText: FlutterI18n.translate(
                                                      context,
                                                      "user_settings.modify_password.confirm_password")),
                                              validator: (value) {
                                                if (value !=
                                                    _passwordController.text) {
                                                  return FlutterI18n.translate(
                                                      context,
                                                      "user_settings.modify_password.input_error_match");
                                                }
                                              },
                                            ),
                                          ),
                                          ElevatedButton(
                                              onPressed: _passwordChangeValid
                                                  ? () {
                                                      final newPassword =
                                                          _passwordController
                                                              .text;
                                                      _modifyPassword(
                                                          newPassword);
                                                      setState(() {
                                                        _isPasswordInputReset =
                                                            true;
                                                        _passwordController
                                                            .clear();
                                                        _confirmPasswordController
                                                            .clear();
                                                        _isPasswordInputReset =
                                                            false;
                                                        _passwordChangeValid =
                                                            false;
                                                      });
                                                    }
                                                  : null,
                                              child: Text(FlutterI18n.translate(
                                                  context,
                                                  "user_settings.submit_button"))),
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
        ChatButtonWidget(scaffoldKey: _scaffoldKey)
      ]),
    );
  }
}
