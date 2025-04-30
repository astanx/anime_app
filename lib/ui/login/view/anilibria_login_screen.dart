import 'package:anime_app/data/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

class AnilibriaLoginScreen extends StatefulWidget {
  const AnilibriaLoginScreen({super.key});

  @override
  State<AnilibriaLoginScreen> createState() => _AnilibriaLoginScreenState();
}

class _AnilibriaLoginScreenState extends State<AnilibriaLoginScreen> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final repository = UserRepository();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login with Anilibria')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: _loginController,
                    decoration: const InputDecoration(
                      labelText: 'Login',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your login';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        final login = _loginController.text;
                        final password = _passwordController.text;

                        final isLogined = await repository.login(
                          login,
                          password,
                        );

                        if (isLogined) {
                          Navigator.of(context).pushNamed('/anime/list');
                        }
                      }
                    },
                    child: const Text('Submit'),
                  ),
                  const SizedBox(height: 24),
                  RichText(
                    text: TextSpan(
                      text: 'Dont have account? ',
                      children: [
                        TextSpan(
                          text: 'Register',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  launchUrl(
                                    Uri.parse(
                                      'https://anilibria.wtf/app/auth/login',
                                    ),
                                  );
                                },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
