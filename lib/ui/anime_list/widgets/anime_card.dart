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
            // Kodik-only anime (movie or series)
            final kodikResult = anime.kodikResult!;
            // Create a minimal Anime object for Kodik anime
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
            // Anilibria anime
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
                anime.poster.optimized.src.isNotEmpty
                    ? '$baseUrl${anime.poster.optimized.src}'
                    : 'https://via.placeholder.com/150',
                width: 150,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Image.network(
                      'https://via.placeholder.com/150',
                      width: 150,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  anime.description.isNotEmpty
                      ? anime.description
                      : 'No description available',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Team {
  final List<String> voice;
  final List<String> translator;
  final List<String> editing;
  final List<String> decor;
  final List<String> timing;

  Team({
    required this.voice,
    required this.translator,
    required this.editing,
    required this.decor,
    required this.timing,
  });

  factory Team.fromJson(Map<String, dynamic> json) => Team(
    voice: List<String>.from(json['voice'] ?? []),
    translator: List<String>.from(json['translator'] ?? []),
    editing: List<String>.from(json['editing'] ?? []),
    decor: List<String>.from(json['decor'] ?? []),
    timing: List<String>.from(json['timing'] ?? []),
  );
}
