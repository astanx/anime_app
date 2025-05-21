import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/kodik_result.dart';
import 'package:anime_app/data/provider/timecode_provider.dart';
import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:flutter/material.dart';

class EpisodeCard extends StatelessWidget {
  const EpisodeCard({
    super.key,
    required this.anime,
    required this.episodeIndex,
    required this.timecodeProvider,
    required this.kodikResult,
  });

  final Anime anime;
  final int episodeIndex;
  final TimecodeProvider timecodeProvider;
  final KodikResult? kodikResult;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () async {
        final animeTitle = await AnimeRepository().getAnimeById(
          anime.release.id,
        );
        Navigator.of(context).pushNamed(
          '/anime',
          arguments: {
            'anime': animeTitle,
            'episodeIndex': episodeIndex,
            'kodikResult': kodikResult,
          },
        );
      },
      child: Card(
        color: theme.cardTheme.color,
        elevation: theme.cardTheme.elevation,
        shadowColor: theme.cardTheme.shadowColor,
        shape: theme.cardTheme.shape,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            'Episode ${anime.episodes[episodeIndex].ordinal}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  timecodeProvider.isWatched(anime.episodes[episodeIndex].id)
                      ? Colors.grey
                      : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
