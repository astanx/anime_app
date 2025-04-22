import 'package:anime_app/ui/anime/anime.dart';
import 'package:anime_app/ui/anime_episodes/view/anime_episodes_screen.dart';
import 'package:anime_app/ui/anime_list/anime_list.dart';
import 'package:anime_app/ui/favourites/view/favourites_screen.dart';
import 'package:anime_app/ui/history/view/history_screen.dart';
import 'package:anime_app/ui/login/login.dart';
import 'package:anime_app/ui/splash/view/splash_screen.dart';

final routes = {
  '/': (context) => const LoginScreen(),
  '/login/anilibria': (context) => const AnilibriaLoginScreen(),
  '/animeList': (context) => const AnimeListScreen(),
  '/anime': (context) => const AnimeScreen(),
  '/anime/episodes': (context) => const AnimeEpisodesScreen(),
  '/splash': (context) => const SplashScreen(),
  '/history': (context) => const HistoryScreen(),
  '/favourites': (context) => const FavouritesScreen(),
};
