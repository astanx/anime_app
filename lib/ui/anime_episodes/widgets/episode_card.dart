import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/mode.dart';
import 'package:anime_app/data/provider/timecode_provider.dart';
import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class EpisodeCard extends StatelessWidget {
  const EpisodeCard({
    super.key,
    required this.anime,
    required this.episodeIndex,
    required this.timecodeProvider,
    required this.mode,
  });

  final Anime anime;
  final int episodeIndex;
  final TimecodeProvider timecodeProvider;
  final Mode mode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final l10n = AppLocalizations.of(context);
    return InkWell(
      onTap: () async {
        final repository = AnimeRepository(mode: mode);
        final animeTitle = await repository.getAnimeById(anime.id);
        Navigator.of(context).pushNamed(
          '/anime',
          arguments: {
            'anime': animeTitle,
            'episodeIndex': episodeIndex,
            'mode': mode,
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
            '${l10n!.episode(0)} ${anime.previewEpisodes[episodeIndex].ordinal}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  timecodeProvider.isWatched(
                        anime.previewEpisodes[episodeIndex].id,
                      )
                      ? Colors.grey
                      : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
