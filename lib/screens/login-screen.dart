import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';

import '../domain/services/auth-service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.title});

  final String title;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final authService = GetIt.I.get<AuthService>();

  // Form objects
  final _usernameFieldController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _validateAndConnect() {
    if (_formKey.currentState!.validate()) {
      authService.connectUser(_usernameFieldController.text);
      Navigator.pop(context);
    }
  }

  String? _validateUsername(username) {
    if (username == null || username.isEmpty || username.trim() == '') {
      return FlutterI18n.translate(context, "form.missing_username");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: 300,
                      child: Form(
                        key: _formKey,
                        child: TextFormField(
                          validator: _validateUsername,
                          controller: _usernameFieldController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: FlutterI18n.translate(
                                context, "form.username_field"),
                          ),
                          onFieldSubmitted: (_) => _validateAndConnect(),
                        ),
                        //TODO: Add text field for password
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _validateAndConnect,
                      child: Text(FlutterI18n.translate(context, "form.login")),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
