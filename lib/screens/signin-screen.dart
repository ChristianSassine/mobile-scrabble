import 'package:flutter/material.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key, required this.title});

  final String title;

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {

  // Form objects
  final _usernameFieldController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _validateAndCreateAccount() {
    //TODO: Validate that the username wasn't already taken
    if (_formKey.currentState!.validate()) {
      //TODO: Call the account creation service
      Navigator.pop(context);
    }
  }

  String? _validateUsername(username) {
    if (username == null || username.isEmpty || username.trim() == '') {
      return "Entrez un nom d'utilisateur avant de soumettre";
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
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Ecrivez votre nom d'utilisateur ici",
                          ),
                          onFieldSubmitted: (_) => _validateAndCreateAccount(),
                        ),
                        //TODO: Add text field for password, email and later avatar selection
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _validateAndCreateAccount,
                      child: const Text("Créer un compte"),
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
