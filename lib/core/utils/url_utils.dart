import 'package:anime_app/core/constants.dart';
import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/anime_release.dart';

String getImageUrl(Object anime) {
  if (anime is Anime) {
    return anime.release.poster.optimized.src.isNotEmpty &&
            anime.release.poster.optimized.src.startsWith('http')
        ? anime.release.poster.optimized.src
        : anime.release.poster.optimized.src.startsWith('/storage')
        ? '$baseUrl${anime.release.poster.optimized.src}'
        : 'https://shikimori.one/${anime.release.poster.optimized.src}';
  } else if (anime is AnimeRelease) {
    return anime.poster.optimized.src.isNotEmpty &&
            anime.poster.optimized.src.startsWith('http')
        ? anime.poster.optimized.src
        : anime.poster.optimized.src.startsWith('/storage')
        ? '$baseUrl${anime.poster.optimized.src}'
        : 'https://shikimori.one/${anime.poster.optimized.src}';
  }
  return '';
}
