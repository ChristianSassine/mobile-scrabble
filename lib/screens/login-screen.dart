import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mobile/components/login-widget.dart';

import '../domain/services/auth-service.dart';

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SizedBox(
                width: 500,
                child: Login(),
              ),
            ],
          ),
        ));
  }
}
