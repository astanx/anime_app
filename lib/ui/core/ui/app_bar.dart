import 'package:anime_app/l10n/app_localizations.dart';
import 'package:anime_app/router/no_animation_route.dart';
import 'package:anime_app/ui/anime_list/view/anime_list_screen.dart';
import 'package:anime_app/ui/collections/view/view.dart';
import 'package:anime_app/ui/favourites/favourites.dart';
import 'package:anime_app/ui/history/view/history_screen.dart';
import 'package:anime_app/ui/search/view/view.dart';
import 'package:anime_app/ui/splash/splash.dart';
import 'package:flutter/material.dart';

class AnimeBar extends StatelessWidget {
  final bool isBlocked;
  const AnimeBar({super.key, this.isBlocked = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentRoute = ModalRoute.of(context)?.settings.name;

    Color activeColor = Theme.of(context).colorScheme.secondary;
    Color inactiveColor = Colors.white;

    Widget routeBuilder(BuildContext context, String route) {
      switch (route) {
        case '/anime/list':
          return AnimeListScreen();
        case '/favourites':
          return FavouritesScreen();
        case '/collections':
          return CollectionsScreen();
        case '/anime/search':
          return SearchScreen();
        case '/history':
          return HistoryScreen();
        default:
          return SplashScreen();
      }
    }

    Widget navItem(String route, IconData icon, String label) {
      final isActive = currentRoute == route;
      final color = isActive ? activeColor : inactiveColor;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              if (!isActive && !isBlocked) {
                Navigator.pushReplacement(
                  context,
                  NoAnimationPageRoute(
                    builder: (context) => routeBuilder(context, route),
                    settings: RouteSettings(name: route),
                  ),
                );
              }
            },
            child: Icon(icon, color: color, size: 30),
          ),
          Text(label, style: TextStyle(fontSize: 10, color: color)),
        ],
      );
    }

    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: kToolbarHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          navItem('/anime/list', Icons.home, l10n.home),
          navItem('/favourites', Icons.star, l10n.favourites),
          navItem('/collections', Icons.folder_open, l10n.collection),
          navItem('/anime/search', Icons.search, l10n.search),
          navItem('/history', Icons.history, l10n.history),
        ],
      ),
    );
  }
}
