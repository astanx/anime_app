import 'package:anime_app/core/utils/url_utils.dart';
import 'package:anime_app/data/models/history.dart';
import 'package:anime_app/l10n/app_localizations.dart';
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
        'showKodik': true,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final onlyKodik = anime.anime.episodes.isEmpty;
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => onlyKodik ? _openKodik(context) : _openNextEpisode(context),
      child: Card(
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
                  getImageUrl(anime.anime),
                  width: 80,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anime.anime.release.names.main,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      onlyKodik
                          ? ''
                          : l10n!.last_watched_episode(
                            anime.lastWatchedEpisode + 1,
                          ),
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (anime.anime.episodes.length >
                            anime.lastWatchedEpisode + 1)
                          Text(
                            anime.isWatched
                                ? l10n!.continue_with_episode(
                                  anime.lastWatchedEpisode + 2,
                                )
                                : l10n!.continue_watching_episode(
                                  anime.lastWatchedEpisode + 1,
                                ),
                            style: TextStyle(
                              fontSize: anime.kodikResult != null ? 12 : 15,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        else
                          Text(
                            onlyKodik
                                ? l10n!.continue_with_kodik
                                : l10n!.no_new_episodes,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        if (anime.kodikResult != null)
                          IconButton(
                            onPressed: () => _openKodik(context),
                            icon: Icon(Icons.play_circle_fill),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
