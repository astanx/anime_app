import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/anime_release.dart';

bool isOngoing(Object anime) {
  if (anime is Anime) {
    return anime.release.isOngoing &&
        anime.episodes.length != anime.release.episodesTotal;
  } else if (anime is AnimeRelease) {
    return anime.isOngoing;
  }
  return false;
}
