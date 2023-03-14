import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/classes/snackbar-factory.dart';
import 'package:mobile/domain/services/auth-service.dart';
import 'package:mobile/screens/menu-screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key, required this.title});

  final String title;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 500,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SignUpForm(),
                ),
              ),
            ),
          ),
        ));
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  bool _valid = false;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();

  final authService = GetIt.I.get<AuthService>();
  late final StreamSubscription loginSub;
  late final StreamSubscription errorSub;

  @override
  void initState() {
    super.initState();

    loginSub = authService.notifyLogin.stream.listen((event) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBarFactory.greenSnack(
          FlutterI18n.translate(context, "auth.signup.success")));
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) =>
                  const MenuScreen(title: "Page de connection")),
          (route) => false);
    });

    errorSub = authService.notifyError.stream.listen((event) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBarFactory.redSnack(
          FlutterI18n.translate(context, "auth.signup.failure")));
    });
  }

  @override
  void dispose() {
    loginSub.cancel();
    errorSub.cancel();
    super.dispose();
  }

  void _registerAccount() {
    authService.createUser(_usernameController.text, _emailController.text,
        _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              FlutterI18n.translate(context, "auth.signup.title"),
              style:
                  DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0),
            ),
            const SizedBox(height: 16),
            TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: FlutterI18n.translate(
                      context, "auth.signup.username_label"),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.length < 3 ||
                      value.length > 16) {
                    return FlutterI18n.translate(
                        context, "auth.signup.username_error");
                  }
                  return null;
                },
                onChanged: (String _) {
                  setState(() {
                    _valid = _formKey.currentState!.validate();
                  });
                }),
            const SizedBox(height: 16),
            TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText:
                      FlutterI18n.translate(context, "auth.signup.email_label"),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(value)) {
                    return FlutterI18n.translate(
                        context, "auth.signup.email_error");
                  }
                  return null;
                },
                onChanged: (String _) {
                  setState(() {
                    _valid = _formKey.currentState!.validate();
                  });
                }),
            const SizedBox(height: 16),
            TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: FlutterI18n.translate(
                      context, "auth.signup.password_label"),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.length < 8 ||
                      value.length > 16) {
                    return FlutterI18n.translate(
                        context, "auth.signup.password_error");
                  }
                  return null;
                },
                onChanged: (String _) {
                  setState(() {
                    _valid = _formKey.currentState!.validate();
                  });
                }),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                hintText: FlutterI18n.translate(
                    context, "auth.signup.password_confirm_label"),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return FlutterI18n.translate(
                      context, "auth.signup.password_confirm_empty");
                }
                if (value != _passwordController.text) {
                  return FlutterI18n.translate(
                      context, "auth.signup.password_confirm_error");
                }
                return null;
              },
              onChanged: (String _) {
                setState(() {
                  _valid = _formKey.currentState!.validate();
                });
              },
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _valid
                    ? () {
                        if (_formKey.currentState!.validate()) {
                          _registerAccount();
                          debugPrint('submitting form ...');
                        }
                      }
                    : null,
                child: Text(FlutterI18n.translate(context, "auth.signup.button")),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
