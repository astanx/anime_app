import 'package:anime_app/core/constants.dart';
import 'package:anime_app/core/utils/url_utils.dart';
import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/anime_release.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Url', () {
    final animeRelease = AnimeRelease(
      id: 1,
      type: AnimeType(value: '', description: ''),
      year: 1,
      names: AnimeNames(main: '', english: ''),
      alias: '1',
      season: AnimeSeason(value: '', description: ''),
      poster: Poster(
        src: 'test_url',
        thumbnail: 'test_url',
        optimized: PosterOptimized(src: 'test_url', thumbnail: 'test_url'),
      ),
      freshAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isOngoing: false,
      ageRating: AgeRating(
        value: '',
        label: '',
        isAdult: false,
        description: '',
      ),
      publishDay: PublishDay(value: 1, description: ''),
      description: '',
      episodesTotal: 1,
      isInProduction: false,
      isBlockedByGeo: false,
      isBlockedByCopyrights: false,
      addedInUsersFavorites: 1,
      averageDurationOfEpisode: 1,
      genres: [],
      latestEpisode: LatestEpisode(
        id: '1',
        name: '',
        ordinal: 10.0,
        preview: EpisodePreview(
          src: '',
          thumbnail: '',
          optimized: EpisodePreviewOptimized(src: '', thumbnail: ''),
        ),
        hls480: '',
        hls720: '',
        hls1080: '',
        duration: 1,
      ),
    );
    final anime = Anime(
      release: animeRelease,
      members: [],
      torrents: [],
      episodes: [],
    );
    group('Anime model', () {
      test('func should work with http start', () {
        final httpAnime = anime.copyWith(
          release: animeRelease.copyWith(
            poster: Poster(
              src: 'http://test_url',
              thumbnail: 'http://test_url',
              optimized: PosterOptimized(
                src: 'http://test_url',
                thumbnail: 'http://test_url',
              ),
            ),
          ),
        );
        expect(getImageUrl(httpAnime), httpAnime.release.poster.src);
      });

      test('func should work with /storage start', () {
        final storageAnime = anime.copyWith(
          release: animeRelease.copyWith(
            poster: Poster(
              src: '/storage/test_url',
              thumbnail: '/storage/test_url',
              optimized: PosterOptimized(
                src: '/storage/test_url',
                thumbnail: '/storage/test_url',
              ),
            ),
          ),
        );
        expect(
          getImageUrl(storageAnime),
          '$baseUrl${storageAnime.release.poster.src}',
        );
      });

      test('func should work with else', () {
        final testAnime = anime.copyWith(
          release: animeRelease.copyWith(
            poster: Poster(
              src: 'test_url',
              thumbnail: 'test_url',
              optimized: PosterOptimized(
                src: 'test_url',
                thumbnail: 'test_url',
              ),
            ),
          ),
        );
        expect(
          getImageUrl(testAnime),
          'https://shikimori.one/${testAnime.release.poster.optimized.src}',
        );
      });
    });

    group('AnimeRelease model', () {
      test('func should work with http start', () {
        final httpAnime = animeRelease.copyWith(
          poster: Poster(
            src: 'http://test_url',
            thumbnail: 'http://test_url',
            optimized: PosterOptimized(
              src: 'http://test_url',
              thumbnail: 'http://test_url',
            ),
          ),
        );
        expect(getImageUrl(httpAnime), httpAnime.poster.src);
      });

      test('func should work with /storage start', () {
        final storageAnime = animeRelease.copyWith(
          poster: Poster(
            src: '/storage/test_url',
            thumbnail: '/storage/test_url',
            optimized: PosterOptimized(
              src: '/storage/test_url',
              thumbnail: '/storage/test_url',
            ),
          ),
        );
        expect(getImageUrl(storageAnime), '$baseUrl${storageAnime.poster.src}');
      });

      test('func should work with else', () {
        final testAnime = animeRelease.copyWith(
          poster: Poster(
            src: 'test_url',
            thumbnail: 'test_url',
            optimized: PosterOptimized(src: 'test_url', thumbnail: 'test_url'),
          ),
        );
        expect(
          getImageUrl(testAnime),
          'https://shikimori.one/${testAnime.poster.optimized.src}',
        );
      });
    });

    test('func should handle another data', () {
      expect(getImageUrl('test'), '');
    });
  });
}
