import 'package:anime_app/data/models/history.dart';
import 'package:flutter/material.dart';

class HistoryCard extends StatelessWidget {
  const HistoryCard({super.key, required this.anime});
  final AnimeWithHistory anime;

  void _openNextEpisode(BuildContext context) {
    Navigator.of(context).pushNamed(
      '/anime',
      arguments: {
        'anime': anime.anime,
        'episodeIndex': anime.lastWatchedEpisode + 1,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openNextEpisode(context),
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
                  'https://anilibria.top${anime.anime.release.poster.optimized.src}',
                  width: 80,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        width: 80,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 40),
                      ),
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
                      'Last watched episode: ${anime.lastWatchedEpisode + 1}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    if (anime.anime.episodes.length >
                        anime.lastWatchedEpisode + 1)
                      Text(
                        'Continue with episode ${anime.lastWatchedEpisode + 2} →',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    else
                      const Text('There is no new episodes :('),
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
