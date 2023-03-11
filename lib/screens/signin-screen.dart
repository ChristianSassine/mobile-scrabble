import 'package:flutter/material.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key, required this.title});
  final String title;

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  // Form objects
  final _formKey = GlobalKey<FormState>();

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
              height: 600,
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

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 16),
          const Text('Email'),
          TextFormField(
            controller: _emailController,
            validator: (value) {
              if (value == null ||
                  value.isEmpty ||
                  !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(value)) {
                return 'Please enter valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          const Text('Username'),
          TextFormField(
            controller: _usernameController,
            validator: (value) {
              if (value == null ||
                  value.isEmpty ||
                  value.length < 3 ||
                  value.length > 16) {
                return 'Please enter your username';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          const Text('Password'),
          TextFormField(
            controller: _passwordController,
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
          ),
          const SizedBox(height: 16),
          const Text('Confirm Password'),
          TextFormField(
            controller: _confirmPasswordController,
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
          ),
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // TODO: Submit Form
                  debugPrint('submitting form ...');
                }
              },
              child: const Text('Register'),
            ),
          ),
        ],
      ),
    );
  }
}
