import 'package:anime_app/ui/anime/anime.dart';
import 'package:anime_app/ui/anime_list/anime_list.dart';
import 'package:anime_app/ui/login/login.dart';

final routes = {
  '/': (context) => const LoginScreen(),
  '/animeList': (context) => const AnimeListScreen(),
  '/anime': (context) => const AnimeScreen(),
};
