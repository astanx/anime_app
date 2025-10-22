import 'package:anime_app/data/models/anime.dart';

bool isOngoing(Anime anime) {
  if (anime.status == 'Completed') return false;
  if (anime.totalEpisodes != anime.previewEpisodes.length) return false;
  return true;
}
