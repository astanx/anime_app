import 'package:anime_app/data/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLoginButton(
                  'Continue with Google',
                  FontAwesomeIcons.google,
                  _handleOAuth(context, 'google'),
                ),
                SizedBox(height: 12),
                _buildLoginButton(
                  'Continue with VK',
                  FontAwesomeIcons.vk,
                  _handleOAuth(context, 'vk'),
                ),
                SizedBox(height: 12),
                _buildLoginButton(
                  'Continue with Patreon',
                  FontAwesomeIcons.patreon,
                  _handleOAuth(context, 'patreon'),
                ),
                SizedBox(height: 12),
                _buildLoginButton(
                  'Continue with Discord',
                  FontAwesomeIcons.discord,
                  _handleOAuth(context, 'discord'),
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

  Future<void> _handleOAuth(BuildContext context, String provider) async {
    final response = await UserRepository().getAuthUrl(provider);
    final authUrl = response.url;

    // This opens the browser and waits for the redirect
    final result = await FlutterWebAuth2.authenticate(
      url: authUrl,
      callbackUrlScheme: "animeapp",
    );

    // The result will be the full redirect URL, like: animeapp://callback?code=123&state=xyz
    final uri = Uri.parse(result);
    final code = uri.queryParameters['code'];
    final state = uri.queryParameters['state'];

    if (code != null && state != null) {
      Navigator.of(context).pushReplacementNamed('/animeList');
    } else {
      // Handle error (e.g. show Snackbar)
    }
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
