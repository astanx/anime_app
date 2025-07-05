import 'package:anime_app/core/constants.dart';
import 'package:anime_app/data/models/anime_release.dart';
import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/data/storage/history_storage.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ReleasesCarousel extends StatelessWidget {
  ReleasesCarousel({super.key, required this.releases});
  final List<AnimeRelease> releases;
  final repository = AnimeRepository();
  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 1 / 3,
      ),
      items:
          releases.map((anime) {
            return Builder(
              builder: (BuildContext context) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    child: Image.network(
                      '$baseUrl${anime.poster.optimized.src}',
                    ),
                    onTap: () async {
                      final animeTitle = await repository.getAnimeById(
                        anime.id,
                        anime.kodikResult,
                      );
                      final episodeIndex = await HistoryStorage.getEpisodeIndex(
                        animeTitle.uniqueId,
                      );
                      Navigator.of(context).pushNamed(
                        '/anime/episodes',
                        arguments: {
                          'anime': animeTitle,
                          'kodikResult':
                              anime.kodikResult ??
                              animeTitle.release.kodikResult,
                          'episodeIndex': episodeIndex,
                        },
                      );
                    },
                  ),
                );
              },
            );
          }).toList(),
    );
  }
}
