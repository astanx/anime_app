import 'package:anime_app/core/utils/url_utils.dart';
import 'package:anime_app/data/models/history.dart';
import 'package:anime_app/data/storage/history_storage.dart';
import 'package:anime_app/l10n/app_localizations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class HistoryCard extends StatelessWidget {
  const HistoryCard({super.key, required this.anime});
  final AnimeWithHistory anime;

  void _openNextEpisode(BuildContext context) {
    Navigator.of(context).pushNamed(
      '/anime',
      arguments: {
        'anime': anime.anime,
        'episodeIndex':
            anime.isWatched
                ? anime.lastWatchedEpisode + 1
                : anime.lastWatchedEpisode,
        'kodikResult': anime.kodikResult,
      },
    );
  }

  void _openKodik(BuildContext context) {
    Navigator.of(context).pushNamed(
      '/anime/episodes',
      arguments: {
        'anime': anime.anime,
        'kodikResult': anime.kodikResult,
        'episodeIndex': anime.lastWatchedEpisode,
        'showKodik': true,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final onlyKodik = anime.anime.episodes.isEmpty;
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                getImageUrl(anime.anime),
                width: 130,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  Text(
                    anime.anime.release.names.main,
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
                    anime.anime.release.id != -1 &&
                            anime.anime.release.episodesTotal > 0
                        ? ''
                        : anime.kodikResult?.type == 'anime'
                        ? l10n.movie
                        : l10n.series,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    width: 500,
                    height: 50,
                    child: TextButton(
                      onPressed: () async {
                        final episodeIndex =
                            await HistoryStorage.getEpisodeIndex(
                              anime.anime.uniqueId,
                            );
                        Navigator.of(context).pushNamed(
                          '/anime/episodes',
                          arguments: {
                            'anime': anime.anime,
                            'kodikResult': anime.anime.release.kodikResult,

                            'episodeIndex': episodeIndex,
                          },
                        );
                      },
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
                      child: Text(l10n.view_anime),
                    ),
                  ),
                  SizedBox(height: 8),

                  if (anime.anime.episodes.length >
                          anime.lastWatchedEpisode + 1 ||
                      !anime.isWatched) ...[
                    SizedBox(
                      width: 500,
                      height: 50,
                      child: TextButton(
                        onPressed: () => _openNextEpisode(context),
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
                          anime.anime.release.episodesTotal > 0
                              ? anime.isWatched
                                  ? l10n.continue_with_episode(
                                    int.parse(
                                          anime
                                              .anime
                                              .episodes[anime
                                                  .lastWatchedEpisode]
                                              .ordinalFormatted,
                                        ) +
                                        1,
                                  )
                                  : l10n.continue_watching_episode(
                                    anime
                                        .anime
                                        .episodes[anime.lastWatchedEpisode]
                                        .ordinalFormatted,
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
                  ] else if (!onlyKodik) ...[
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
                  if (anime.kodikResult != null)
                    SizedBox(
                      width: 500,
                      height: 50,
                      child: TextButton(
                        onPressed: () => _openKodik(context),
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
                          l10n.continue_with_kodik,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),

                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                  const SizedBox(height: 2),
                  if (anime.anime.release.id != -1 &&
                      anime.anime.release.episodesTotal > 0) ...[
                    Text(
                      '${anime.anime.episodes[anime.lastWatchedEpisode].ordinalFormatted} / ${l10n.episode_count(anime.anime.release.episodesTotal)}',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value:
                            anime.anime.release.episodesTotal > 0
                                ? anime
                                        .anime
                                        .episodes[anime.lastWatchedEpisode]
                                        .ordinal /
                                    anime.anime.release.episodesTotal
                                : 0.0,
                        minHeight: 6,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFAD1CB4),
                        ),
                      ),
                    ),
                  ],

                  if (anime.anime.release.id == -1 &&
                      anime.anime.release.episodesTotal > 0) ...[
                    Text(
                      '${anime.lastWatchedEpisode} / ${l10n.episode_count(anime.anime.release.episodesTotal)}',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value:
                            anime.anime.release.episodesTotal > 0
                                ? anime.lastWatchedEpisode /
                                    anime.anime.release.episodesTotal
                                : 0.0,
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
