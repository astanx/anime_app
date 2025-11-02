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

    Widget navItem(
      List<String> routes,
      IconData icon,
      String label,
      double iconSize,
      double fontSize,
    ) {
      final isActive = routes.contains(currentRoute);
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
                    builder: (context) => routeBuilder(context, routes.first),
                    settings: RouteSettings(name: routes.first),
                  ),
                );
              }
            },
            child: Icon(icon, color: color, size: iconSize),
          ),
          SizedBox(height: fontSize * 0.25),
          Text(label, style: TextStyle(fontSize: fontSize, color: color)),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final baseWidth = 360.0;
        final width = constraints.maxWidth;
        final scale = (width / baseWidth).clamp(1.0, 1.6);

        final barHeight = kToolbarHeight * scale;
        final iconSize = 30.0 * scale;
        final fontSize = 10.0 * scale;
        final horizontalPadding = 8.0 * scale;

        return Container(
          color: Theme.of(context).appBarTheme.backgroundColor,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          height: barHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              navItem(
                ['/anime/list'],
                Icons.home,
                l10n.home,
                iconSize,
                fontSize,
              ),
              navItem(
                ['/favourites'],
                Icons.star,
                l10n.favourites,
                iconSize,
                fontSize,
              ),
              navItem(
                ['/collections'],
                Icons.folder_open,
                l10n.collection,
                iconSize,
                fontSize,
              ),
              navItem(
                ['/anime/search', '/anime/releases'],
                Icons.search,
                l10n.search,
                iconSize,
                fontSize,
              ),
              navItem(
                ['/history'],
                Icons.history,
                l10n.history,
                iconSize,
                fontSize,
              ),
            ],
          ),
        );
      },
    );
  }
}
