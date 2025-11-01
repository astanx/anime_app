import 'package:anime_app/data/models/search_anime.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ReleasesCarousel extends StatelessWidget {
  const ReleasesCarousel({
    super.key,
    required this.releases,
    required this.isWide,
  });
  final bool isWide;
  final List<SearchAnime> releases;
  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: isWide ? 400 : 200,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: isWide ? 1 / 3 : 1 / 2.5,
      ),
      items:
          releases.map((anime) {
            return Builder(
              builder: (BuildContext context) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    child: Image.network(anime.poster),
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        '/anime/episodes',
                        arguments: {'animeID': anime.id},
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
