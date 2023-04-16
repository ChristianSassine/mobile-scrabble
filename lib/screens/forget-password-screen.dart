import "package:flutter/material.dart";
import "package:flutter_i18n/flutter_i18n.dart";
import "package:get_it/get_it.dart";
import "package:mobile/domain/classes/snackbar-factory.dart";
import "package:mobile/domain/enums/server-events-enum.dart";
import "package:mobile/domain/services/user-service.dart";

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _inputKey = GlobalKey<FormFieldState>();
  final _userService = GetIt.I.get<UserService>();
  final _inputController = TextEditingController();
  bool _isValid = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            FlutterI18n.translate(context, "auth.forgot_pass.screen_title")),
      ),
      body: Center(
        child: Card(
          child: Container(
            width: size.width * 0.3,
            height: size.height * 0.3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    FlutterI18n.translate(context, "auth.forgot_pass.title"),
                    style: theme.textTheme.titleLarge,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      FlutterI18n.translate(
                      context, "auth.forgot_pass.description"),
                      style: theme.textTheme.labelMedium,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      key: _inputKey,
                      controller: _inputController,
                      onChanged: (value) {
                        setState(() {
                          _isValid = _inputKey.currentState!.validate();
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return FlutterI18n.translate(
                              context, "auth.forgot_pass.error");
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: FlutterI18n.translate(
                            context, "auth.forgot_pass.hint"),
                      ),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: _isValid
                          ? () {
                              _userService
                                  .forgotPassword(_inputController.text)
                                  .then((event) {
                                if (event ==
                                    ServerEvents.EmailPasswordSuccess) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBarFactory.greenSnack(
                                          FlutterI18n.translate(context,
                                              "auth.forgot_pass.success")));
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBarFactory.redSnack(
                                        FlutterI18n.translate(
                                            context, "auth.forgot_pass.fail")));
                              });
                              setState(() {
                                _inputController.clear();
                                _isValid = false;
                              });
                            }
                          : null,
                      child: Text(FlutterI18n.translate(
                          context, "auth.forgot_pass.submit")))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
