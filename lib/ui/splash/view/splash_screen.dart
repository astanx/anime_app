import 'package:anime_app/data/repositories/user_repository.dart';
import 'package:anime_app/data/storage/token_storage.dart';
import 'package:anime_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _serverAlive = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    setState(() {
      _loading = true;
      _serverAlive = true;
    });

    final userRepository = UserRepository();
    final isAlive = await userRepository.checkServerStatus();

    if (!isAlive) {
      setState(() {
        _serverAlive = false;
        _loading = false;
      });
      return;
    }

    final token = await TokenStorage.getToken();

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        token != null ? '/anime/list' : '/',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_serverAlive) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  l10n.server_unavailable,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: _initApp, child: Text(l10n.retry)),
              ],
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
