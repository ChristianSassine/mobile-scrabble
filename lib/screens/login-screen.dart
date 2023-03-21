import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mobile/components/login-widget.dart';
import 'package:mobile/screens/signup-screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.title});

  final String title;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 500,
                  child: Login(),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SignupScreen(
                              title: FlutterI18n.translate(context, 'menu_screen.sign_up_screen'))));
                    },
                    child: Text(FlutterI18n.translate(context, 'auth.login.button_sign_up')))
              ],
            ),
          ),
        ));
  }
}
