import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

class SignInState extends ChangeNotifier {
  bool formsValid = false;

  void updateValidity(bool validity) {
    formsValid = validity;
    notifyListeners();
  }

  bool isValid() {
    return formsValid;
  }
}

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignInState(),
      child: ContainerLogin(),
    );
  }
}

class ContainerLogin extends StatefulWidget {
  const ContainerLogin({super.key});

  @override
  State<ContainerLogin> createState() => _ContainerLoginState();
}

class _ContainerLoginState extends State<ContainerLogin> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var signinState = context.watch<SignInState>();
    return Card(
      child: Column(
        children: [
          Form(
              key: _formKey,
              child: Column(
                children: [
                  UsernameInput(
                    formKey: _formKey,
                  ),
                  PasswordInput(formKey: _formKey),
                ],
              )),
          ElevatedButton(
            onPressed: signinState.isValid()
                ? () {
                    if (_formKey.currentState!.validate()) {}
                  }
                : null,
            child: Text('Sign in'),
          )
        ],
      ),
    );
  }
}

class PasswordInput extends StatelessWidget {
  const PasswordInput({
    Key? key,
    required this.formKey,
  }) : super(key: key);

  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    var signinState = context.watch<SignInState>();

    return TextFormField(
      obscureText: true,
      enableSuggestions: false,
      autocorrect: false,
      validator: (value) {
        if (value == null || value.isEmpty || value.trim() == '') {
          return 'Entrez un mot de passe';
        }
        return null;
      },
      onChanged: (_) =>
          {signinState.updateValidity(formKey.currentState!.validate())},
      onFieldSubmitted: (String _) {
        formKey.currentState!.validate();
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: "Entrez votre mot de passe",
      ),
    );
  }
}

class UsernameInput extends StatelessWidget {
  const UsernameInput({
    Key? key,
    required this.formKey,
  }) : super(key: key);

  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    var signinState = context.watch<SignInState>();

    return TextFormField(
      autocorrect: false,
      validator: (value) {
        if (value == null || value.isEmpty || value.trim() == '') {
          return "Entrer un nom d'utilisateur";
        }
        return null;
      },
      onFieldSubmitted: (String _) {
        formKey.currentState!.validate();
      },
      onChanged: (_) =>
          {signinState.updateValidity(formKey.currentState!.validate())},
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: "Entrez votre nom d'utilisateur",
      ),
    );
  }
}
