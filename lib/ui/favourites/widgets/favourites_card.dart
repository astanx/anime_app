import 'package:anime_app/core/constants.dart';
import 'package:anime_app/data/models/anime.dart';
import 'package:flutter/material.dart';

class FavouritesCard extends StatelessWidget {
  const FavouritesCard({super.key, required this.anime});
  final Anime anime;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => {
            Navigator.of(context).pushNamed(
              '/anime/episodes',
              arguments: {
                'anime': anime,
                'kodikResult': anime.release.kodikResult,
              },
            ),
          },
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
                  anime.release.poster.optimized.src.isNotEmpty &&
                          anime.release.poster.optimized.src.startsWith('http')
                      ? anime.release.poster.optimized.src
                      : '$baseUrl${anime.release.poster.optimized.src}',
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
                      anime.release.names.main,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${anime.release.year}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
