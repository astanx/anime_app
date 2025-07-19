import 'package:anime_app/core/utils/is_ongoing.dart';
import 'package:anime_app/core/utils/url_utils.dart';
import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/storage/history_storage.dart';
import 'package:anime_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class CollectionCard extends StatelessWidget {
  const CollectionCard({super.key, required this.anime});
  final Anime anime;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                getImageUrl(anime),
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
                    anime.release.names.main,
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
                    '${anime.release.year}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  Text(
                    anime.release.episodesTotal > 0
                        ? '${l10n.episode_count(anime.release.episodesTotal)} ${isOngoing(anime) ? '| ${l10n.ongoing}' : ''}'
                        : anime.typeLabel(l10n),
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                  if (anime.release.description != null)
                    Text(
                      anime.release.description!,
                      maxLines: 6,
                      textAlign: TextAlign.center,
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
                              anime.uniqueId,
                            );
                        Navigator.of(context).pushNamed(
                          '/anime/episodes',
                          arguments: {
                            'anime': anime,
                            'kodikResult': anime.release.kodikResult,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
