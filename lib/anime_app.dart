import 'package:anime_app/l10n/app_localizations.dart';
import 'package:anime_app/router/router.dart';
import 'package:anime_app/ui/core/theme/theme.dart';
import 'package:flutter/material.dart';

class AnimeApp extends StatelessWidget {
  const AnimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      title: 'Anime List',
      theme: darkTheme,
      routes: routes,
      initialRoute: '/splash',
    );
  }
}
