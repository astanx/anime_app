import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login'), automaticallyImplyLeading: false),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLoginButton(
                  'Continue with Anilibria',
                  FontAwesomeIcons.a,
                  () {
                    Navigator.of(context).pushNamed('/login/anilibria');
                  },
                ),
                SizedBox(height: 12),
                _buildLoginButton('Continue without login', Icons.person, () {
                  Navigator.of(context).pushNamed('/animeList');
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
