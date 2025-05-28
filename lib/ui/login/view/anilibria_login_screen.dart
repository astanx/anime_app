import 'package:anime_app/data/repositories/user_repository.dart';
import 'package:anime_app/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.login_title)),
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
                    decoration: InputDecoration(
                      labelText: l10n.login_label,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.login_empty_error;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: l10n.password_label,
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.password_empty_error;
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
                    child: Text(l10n.submit_button),
                  ),
                  const SizedBox(height: 24),
                  RichText(
                    text: TextSpan(
                      text: l10n.no_account_text,
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        TextSpan(
                          text: l10n.register_text,
                          style: const TextStyle(
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
