import 'package:anime_app/data/models/anime.dart';
import 'package:flutter/material.dart';

class AnimeCard extends StatelessWidget {
  const AnimeCard({super.key, required this.anime});

  final Anime anime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); 

    return Card(
      color: theme.cardTheme.color, 
      elevation: theme.cardTheme.elevation, 
      shadowColor: theme.cardTheme.shadowColor, 
      shape: theme.cardTheme.shape, 
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Image.network(
              'https://anilibria.top${anime.poster.optimized.src}',
              width: 150,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 8),
            Text(
              anime.names.main,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 16, 
                fontWeight: FontWeight.bold,
                
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            // Статус "Ongoing"
            Text(
              'Ongoing: ${anime.isOngoing == "ongoing" ? "Yes" : "No"}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12, 
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            // Описание аниме
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                anime.description,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
