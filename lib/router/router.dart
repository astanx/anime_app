import 'package:anime_app/ui/anime/anime.dart';
import 'package:anime_app/ui/anime_episodes/anime_episodes.dart';
import 'package:anime_app/ui/anime_list/anime_list.dart';
import 'package:anime_app/ui/collections/collections.dart';
import 'package:anime_app/ui/favourites/favourites.dart';
import 'package:anime_app/ui/franchise_list/franchise_list.dart';
import 'package:anime_app/ui/history/history.dart';
import 'package:anime_app/ui/login/login.dart';
import 'package:anime_app/ui/search/search.dart';
import 'package:anime_app/ui/splash/splash.dart';

final routes = {
  '/': (context) => const LoginScreen(),
  '/login/anilibria': (context) => const AnilibriaLoginScreen(),
  '/anime/list': (context) => const AnimeListScreen(),
  '/anime': (context) => const AnimeScreen(),
  '/anime/episodes': (context) => const AnimeEpisodesScreen(),
  '/splash': (context) => const SplashScreen(),
  '/history': (context) => const HistoryScreen(),
  '/favourites': (context) => const FavouritesScreen(),
  '/genre/releases': (context) => const GenreReleasesScreen(),
  '/anime/franchise': (context) => const FranchiseScreen(),
  '/collections': (context) => const CollectionsScreen(),
  '/anime/search': (context) => const SearchScreen(),
};
