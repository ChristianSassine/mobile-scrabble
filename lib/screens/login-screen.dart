import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Page de connection"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: 300,
                      child: Form(
                        key: _formKey,
                        child: TextFormField(
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.trim() == '') {
                              return "Entrez un nom d'utilisateur avant de soumettre";
                            }
                            return null;
                          },
                          controller: _usernameFieldController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Ecrivez votre nom d'utilisateur ici",
                          ),
                          onFieldSubmitted: (String _) {
                            if (_formKey.currentState!.validate()) {
                              authService.connectUser(_usernameFieldController.text);
                            }
                          },
                        ),
                        //TODO: Add text field for password
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          authService.connectUser(_usernameFieldController.text);
                          Navigator.pop(context);
                        }
                        //TODO: Validate all form information => Return to menu if successful
                      },
                      child: Text("Se connecter"),
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
