import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/domain/classes/snackbar-factory.dart';
import 'package:mobile/domain/services/auth-service.dart';
import 'package:mobile/screens/menu-screen.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key, required this.title});

  final String title;

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBarFactory.greenSnack("Compte créer!"));
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) =>
                  const MenuScreen(title: "Page de connection")),
          (route) => false);
    });

    errorSub = authService.notifyError.stream.listen((event) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBarFactory.redSnack("Echec lors de la création du compte!"));
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
              "Créer un compte",
              style:
                  DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  hintText: "Username",
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.length < 3 ||
                      value.length > 16) {
                    return 'Please enter your username';
                  }
                  return null;
                },
                onChanged: (String _) {
                  setState(() {
                    _valid = _formKey.currentState!.validate();
                  });
                }),
            TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: "Email",
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(value)) {
                    return 'Please enter valid email';
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
                decoration: const InputDecoration(
                  hintText: "Password",
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.length < 8 ||
                      value.length > 16) {
                    return 'Please enter your password';
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
              decoration: const InputDecoration(
                hintText: "Confirm Password",
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
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
                child: const Text('Register'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
