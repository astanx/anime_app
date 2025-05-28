import 'package:anime_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n!.login_label),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLoginButton(l10n.login_title, FontAwesomeIcons.a, () {
                  Navigator.of(context).pushNamed('/login/anilibria');
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(String text, IconData icon, onPressed) {
    return SizedBox(
      width: 300,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(text), Icon(icon)],
        ),
      ),
    );
  }
}
