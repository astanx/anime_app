import 'package:anime_app/core/constants.dart';
import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/anime_release.dart';
import 'package:anime_app/data/repositories/anime_repository.dart';
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
        try {
          if (anime.id == -1 && anime.kodikResult != null) {
            final kodikResult = anime.kodikResult!;
            final kodikAnime = Anime(
              release: anime,
              episodes: [],
              torrents: [],
              members: [],
            );
            Navigator.of(context).pushNamed(
              '/anime/episodes',
              arguments: {'anime': kodikAnime, 'kodikResult': kodikResult},
            );
          } else {
            final animeTitle = await repository.getAnimeById(anime.id);
            Navigator.of(context).pushNamed(
              '/anime/episodes',
              arguments: {
                'anime': animeTitle,
                'kodikResult': anime.kodikResult,
              },
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading anime: $e'),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      },
      child: Card(
        color: theme.cardTheme.color,
        elevation: theme.cardTheme.elevation,
        shadowColor: theme.cardTheme.shadowColor,
        shape: theme.cardTheme.shape,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Image.network(
                anime.poster.optimized.src.isNotEmpty &&
                        anime.poster.optimized.src.startsWith('http')
                    ? anime.poster.optimized.src
                    : '$baseUrl${anime.poster.optimized.src}',
                width: 150,
                height: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 8),
              Text(
                anime.names.main,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
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
    );
  }
}
