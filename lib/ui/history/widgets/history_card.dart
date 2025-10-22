import 'package:anime_app/data/models/history.dart';
import 'package:anime_app/data/models/mode.dart';
import 'package:anime_app/l10n/app_localizations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class HistoryCard extends StatelessWidget {
  const HistoryCard({super.key, required this.historyData, required this.mode});
  final AnimeWithHistory historyData;
  final Mode mode;

  void _openNextEpisode(BuildContext context) {
    Navigator.of(context).pushNamed(
      '/anime',
      arguments: {
        'anime': historyData.anime,
        'episodeIndex':
            historyData.history.isWatched
                ? historyData.history.lastWatchedEpisode + 1
                : historyData.history.lastWatchedEpisode,
        'mode': mode,
      },
    );
  }

  void _openMovie(BuildContext context) {
    Navigator.of(context).pushNamed(
      '/anime/episodes',
      arguments: {'anime': historyData.anime, 'episodeIndex': 0},
    );
  }

  void _openAnime(BuildContext context) async {
    Navigator.of(
      context,
    ).pushNamed('/anime/episodes', arguments: {'anime': historyData.anime});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                historyData.anime.poster,
                width: 130,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    historyData.anime.title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    historyData.anime.type,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: 500,
                    height: 50,
                    child: TextButton(
                      onPressed: () => _openAnime(context),
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF6B5252),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Text(
                        historyData.anime.isMovie
                            ? l10n.view_film
                            : l10n.view_anime,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  if (historyData.anime.previewEpisodes.length >
                          historyData.history.lastWatchedEpisode + 1 ||
                      !historyData.history.isWatched) ...[
                    SizedBox(
                      width: 500,
                      height: 50,
                      child: TextButton(
                        onPressed:
                            !historyData.anime.isMovie
                                ? () => _openNextEpisode(context)
                                : () => _openMovie(context),
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF6B5252),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: AutoSizeText(
                          !historyData.anime.isMovie
                              ? historyData.history.isWatched
                                  ? l10n.continue_with_episode(
                                    historyData
                                            .anime
                                            .previewEpisodes[historyData
                                                .history
                                                .lastWatchedEpisode]
                                            .ordinal +
                                        1,
                                  )
                                  : l10n.continue_watching_episode(
                                    historyData
                                        .anime
                                        .previewEpisodes[historyData
                                            .history
                                            .lastWatchedEpisode]
                                        .ordinal,
                                  )
                              : l10n.continue_watching_movie,
                          maxFontSize: 14,
                          minFontSize: 10,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                  ] else if (!historyData.anime.isMovie) ...[
                    SizedBox(
                      width: 500,
                      height: 50,
                      child: TextButton(
                        onPressed: () => {},
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF6B5252),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Text(
                          l10n.no_new_episodes,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),

                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                  ],

                  const SizedBox(height: 2),
                  if (historyData.anime.totalEpisodes > 0 &&
                      !historyData.anime.isMovie) ...[
                    Text(
                      '${historyData.anime.previewEpisodes[historyData.history.lastWatchedEpisode].ordinal} / ${l10n.episode_count(historyData.anime.totalEpisodes)}',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value:
                            historyData
                                .anime
                                .previewEpisodes[historyData
                                    .history
                                    .lastWatchedEpisode]
                                .ordinal /
                            historyData.anime.totalEpisodes,
                        minHeight: 6,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFAD1CB4),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
