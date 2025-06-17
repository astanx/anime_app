import 'package:anime_app/core/utils/url_utils.dart';
import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/anime_release.dart';
import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/data/storage/history_storage.dart';
import 'package:flutter/material.dart';

class AnimeCard extends StatelessWidget {
  AnimeCard({super.key, required this.anime});

  final AnimeRelease anime;
  final repository = AnimeRepository();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () async {
        if (anime.id == -1 && anime.kodikResult != null) {
          final kodikResult = anime.kodikResult!;
          final kodikAnime = Anime(
            release: anime,
            episodes: [],
            torrents: [],
            members: [],
          );
          final episodeIndex = await HistoryStorage.getEpisodeIndex(
            kodikAnime.uniqueId,
          );
          Navigator.of(context).pushNamed(
            '/anime/episodes',
            arguments: {
              'anime': kodikAnime,
              'kodikResult': kodikResult,
              'episodeIndex': episodeIndex,
            },
          );
        } else {
          final animeTitle = await repository.getAnimeById(anime.id);
          final episodeIndex = await HistoryStorage.getEpisodeIndex(
            animeTitle.uniqueId,
          );
          Navigator.of(context).pushNamed(
            '/anime/episodes',
            arguments: {
              'anime': animeTitle,
              'kodikResult': anime.kodikResult,
              'episodeIndex': episodeIndex,
            },
          );
        }
      },

      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                width: 200,
                height: 300,
                getImageUrl(anime),
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      anime.names.main,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 4,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${anime.year}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
