import 'package:anime_app/data/models/search_anime.dart';
import 'package:flutter/material.dart';

class AnimeCard extends StatelessWidget {
  const AnimeCard({super.key, required this.anime, required this.isWide});
  final bool isWide;
  final SearchAnime anime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        Navigator.of(
          context,
        ).pushNamed('/anime/episodes', arguments: {'animeID': anime.id});
      },

      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                width: isWide ? 400 : 200,
                height: isWide ? 500 : 300,
                anime.poster,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      anime.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: isWide ? 26 : 14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: isWide ? 2 : 4,
                      textAlign: TextAlign.center,
                    ),
                    if (anime.year != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${anime.year}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: isWide ? 22 : 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
