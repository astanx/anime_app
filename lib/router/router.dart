import 'package:anime_app/ui/anime/anime.dart';
import 'package:anime_app/ui/anime_episodes/anime_episodes.dart';
import 'package:anime_app/ui/anime_list/anime_list.dart';
import 'package:anime_app/ui/collections/collections.dart';
import 'package:anime_app/ui/favourites/favourites.dart';
import 'package:anime_app/ui/history/history.dart';
import 'package:anime_app/ui/mode/mode.dart';
import 'package:anime_app/ui/search/search.dart';
import 'package:anime_app/ui/splash/splash.dart';

final routes = {
  '/': (context) => ModeScreen(),
  '/anime/list': (context) => const AnimeListScreen(),
  '/anime': (context) => const AnimeScreen(),
  '/anime/episodes': (context) => const AnimeEpisodesScreen(),
  '/splash': (context) => const SplashScreen(),
  '/history': (context) => const HistoryScreen(),
  '/favourites': (context) => const FavouritesScreen(),
  '/anime/releases': (context) => const AnimeReleasesScreen(),
  '/collections': (context) => const CollectionsScreen(),
  '/anime/search': (context) => const SearchScreen(),
};
