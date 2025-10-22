import 'package:anime_app/core/utils/is_ongoing.dart';
import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class FavouritesCard extends StatelessWidget {
  const FavouritesCard({super.key, required this.anime});
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
                anime.poster,
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
                    anime.title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  if (anime.year != null)
                    Text(
                      '${anime.year}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  if (anime.totalEpisodes > 0)
                    Text(
                      '${l10n.episode_count(anime.totalEpisodes)}${isOngoing(anime) ? ' | ${l10n.ongoing}' : ''}',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  if (anime.description.isNotEmpty)
                    Text(
                      anime.description,
                      maxLines: 6,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: 500,
                    height: 50,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          '/anime/episodes',
                          arguments: {'anime': anime},
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
