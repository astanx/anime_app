import 'package:anime_app/core/constants.dart';
import 'package:anime_app/data/models/anime_release.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ReleasesCarousel extends StatelessWidget {
  const ReleasesCarousel({super.key, required this.releases});
  final List<AnimeRelease> releases;
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
                  child: Image.network('$baseUrl${anime.poster.optimized.src}'),
                );
              },
            );
          }).toList(),
    );
  }
}
