import 'dart:developer';
import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/anime_release.dart';
import 'package:anime_app/data/models/franchise.dart';
import 'package:anime_app/data/models/kodik_result.dart';
import 'package:anime_app/data/models/shikimori_anime.dart';
import 'package:anime_app/data/repositories/base_repository.dart';
import 'package:anime_app/data/services/dio_client.dart';
import 'package:dio/dio.dart';

class AnimeRepository extends BaseRepository {
  AnimeRepository() : super(DioClient().dio);
  String _normalizeTitle(String? title) {
    if (title == null) return '';

    String noParentheses = title.replaceAll(RegExp(r'\([^)]*\)'), '');

    List<String> words = noParentheses.toLowerCase().split(
      RegExp(r'[^\wа-яё]+', caseSensitive: false),
    );

    const noiseWords = {
      'tv',
      'tb',
      'ova',
      'ona',
      'special',
      'movie',
      'usj',
      'bd',
      'dvd',
      'hd',
      'sd',
      'remastered',
      'dc',
      'se',
      'edition',
      'part',
      'тв',
      'тб',
      'спешл',
      'фильм',
      'сезон',
      'серия',
      'озвучка',
      'субтитры',
      'ремастер',
      'хд',
      'сд',
      'двд',
      'бд',
      's',
      'season',
    };

    words =
        words
            .where((word) => word.isNotEmpty && !noiseWords.contains(word))
            .toList();

    return words.join();
  }

  Future<List<AnimeRelease>> getWeekSchedule() async {
    try {
      final response = await dio.get('anime/schedule/week');

      final data = response.data as List<dynamic>;
      final schedule =
          data.map((json) => AnimeRelease.fromJson(json["release"])).toList();
      return schedule;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AnimeRelease>> searchAnime(String query) async {
    try {
      final anilibriaResponse = await dio.get(
        'app/search/releases?query=$query',
      );
      final anilibriaData = anilibriaResponse.data as List<dynamic>;
      final anilibriaReleases =
          anilibriaData.map((json) => AnimeRelease.fromJson(json)).toList();

      final kodikResultsRaw = await searchKodik(query);
      final kodikResults = _deduplicateKodikByShikimori(kodikResultsRaw);

      final matchedReleases = <AnimeRelease>[];
      final matchedKodikIds = <String>{};

      for (var release in anilibriaReleases) {
        final names =
            [
                  release.names.main,
                  release.names.english,
                  release.names.alternative,
                ]
                .where((n) => n != null && n.isNotEmpty)
                .map(_normalizeTitle)
                .toList();

        KodikResult? matchedKodik;
        for (var k in kodikResults) {
          final kodikTitles =
              [
                k.title,
                k.titleOrig,
                k.otherTitle,
              ].where((t) => t.isNotEmpty).map(_normalizeTitle).toList();

          final hasMatch = names.any((n) => kodikTitles.contains(n));
          if (hasMatch) {
            matchedKodik = k;
            break;
          }
        }

        if (matchedKodik != null) {
          matchedReleases.add(
            AnimeRelease.fromAnilibriaAndKodik(release, matchedKodik),
          );
          matchedKodikIds.add(matchedKodik.id);
        } else {
          matchedReleases.add(release);
        }
      }

      final remainingKodik =
          kodikResults.where((k) => !matchedKodikIds.contains(k.id)).toList();

      final movieResults =
          remainingKodik.where((k) => k.type == 'anime').toList();
      final seriesResults =
          remainingKodik.where((k) => k.type == 'anime-serial').toList();

      final seriesGroups = <String, List<KodikResult>>{};
      for (var k in seriesResults) {
        if (k.shikimoriId != null) {
          seriesGroups.putIfAbsent(k.shikimoriId!, () => []).add(k);
        }
      }

      final movieReleases = <AnimeRelease>[];
      for (var m in movieResults) {
        if (m.shikimoriId != null) {
          try {
            final shikimoriAnime = await getShikimoriAnimeById(m.shikimoriId!);
            movieReleases.add(
              AnimeRelease.fromKodikAndShikimori(m, shikimoriAnime),
            );
          } catch (e) {
            log('Error fetching Shikimori data for movie: $e');
            movieReleases.add(AnimeRelease.fromKodik(m));
          }
        } else {
          movieReleases.add(AnimeRelease.fromKodik(m));
        }
      }

      final seriesReleases = <AnimeRelease>[];
      for (var group in seriesGroups.values) {
        final first = group.first;
        try {
          final shikimoriAnime = await getShikimoriAnimeById(
            first.shikimoriId!,
          );
          seriesReleases.add(
            AnimeRelease.fromKodikAndShikimori(first, shikimoriAnime),
          );
        } catch (e) {
          log('Error fetching Shikimori data for series: $e');
          seriesReleases.add(AnimeRelease.fromKodik(first));
        }
      }

      return [...matchedReleases, ...movieReleases, ...seriesReleases];
    } catch (e) {
      log('Error searching anime: $e');
      rethrow;
    }
  }

  Future<KodikResult?> matchKodikWithAnilibria(Anime anime) async {
    try {
      final kodikAnimes = await searchKodik(anime.release.names.main);
      final matched = matchAnimeWithKodik([anime], kodikAnimes);
      return matched.matched.first.release.kodikResult;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<KodikResult>> searchKodik(String query) async {
    try {
      final response = await dio.get(
        'https://kodikapi.com/search',
        queryParameters: {
          'token': '447d179e875efe44217f20d1ee2146be',
          'title': query,
        },
      );
      final data = response.data['results'] as List<dynamic>;
      return data.map((json) => KodikResult.fromJson(json)).toList();
    } catch (e) {
      log('Error searching Kodik: $e');
      rethrow;
    }
  }

  Future<List<KodikResult>> getAnimeByKodikId(int id) async {
    try {
      final response = await dio.get(
        'https://kodikapi.com/search',
        queryParameters: {
          'token': '447d179e875efe44217f20d1ee2146be',
          'shikimori_id': id,
        },
      );
      final data = response.data['results'] as List<dynamic>;
      return data.map((json) => KodikResult.fromJson(json)).toList();
    } catch (e) {
      log('Error searching Kodik: $e');
      rethrow;
    }
  }

  Future<ShikimoriAnime> getShikimoriAnimeById(String shikimoriId) async {
    try {
      final response = await Dio().get(
        'https://shikimori.one/api/animes/$shikimoriId',
      );
      final data = response.data as Map<String, dynamic>;
      final anime = ShikimoriAnime.fromJson(data);
      return anime;
    } catch (e) {
      rethrow;
    }
  }

  Future<Anime> getAnimeById(int id, [KodikResult? kodik]) async {
    try {
      final response = await dio.get('anime/releases/$id');
      final data = response.data;

      log(data.toString());

      final anime = Anime.fromJson(data);

      if (kodik == null) {
        final kodikResults = await searchKodik(anime.release.names.main);
        final matchResult = matchAnimeWithKodik([anime], kodikResults);
        final matchedAnime = matchResult.matched.firstOrNull;
        return matchedAnime ?? anime;
      }
      return anime;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AnimeRelease>> getReleases(int? limit) async {
    try {
      limit ??= 10;
      final response = await dio.get('anime/releases/latest?limit=$limit');
      final data = response.data as List<dynamic>;

      log(data.toString());

      final releases = data.map((json) => AnimeRelease.fromJson(json)).toList();

      return releases;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Genre>> getGenres(int? limit) async {
    try {
      limit ??= 8;
      final response = await dio.get('anime/genres/random?limit=$limit');
      final data = response.data as List<dynamic>;

      log(data.toString());

      final genres = data.map((g) => Genre.fromJson(g)).toList();

      return genres;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AnimeRelease>> getGenresReleases(
    int genreId,
    int? page,
    int? limit,
  ) async {
    try {
      page ??= 1;
      limit ??= 16;
      final response = await dio.get(
        'anime/genres/$genreId/releases?page=$page&limit=$limit',
      );
      final data = response.data as Map<String, dynamic>;
      final releasesData = data['data'] as List<dynamic>;

      log(data.toString());

      final releases =
          releasesData.map((r) => AnimeRelease.fromJson(r)).toList();

      return releases;
    } catch (e) {
      rethrow;
    }
  }

  Future<Franchise> getFranchiseById(int releaseId) async {
    try {
      final response = await dio.get('anime/franchises/release/$releaseId');
      final data = response.data as List<dynamic>;

      log(data.toString());

      final franchise = Franchise.fromJson(data[0]);

      return franchise;
    } catch (e) {
      rethrow;
    }
  }

  List<KodikResult> _deduplicateKodikByShikimori(List<KodikResult> results) {
    final uniqueByShikimori = <String, KodikResult>{};

    for (var result in results) {
      final id = result.shikimoriId;
      if (id != null && !uniqueByShikimori.containsKey(id)) {
        uniqueByShikimori[id] = result;
      }
    }

    return uniqueByShikimori.values.toList();
  }

  MatchResult matchAnimeWithKodik(
    List<Anime> anilibriaAnimes,
    List<KodikResult> kodikResults,
  ) {
    final matchedReleases = <Anime>[];
    final matchedKodikIds = <String>{};

    // Create a map of normalized Kodik titles to KodikResult for faster lookup
    final kodikTitleMap = <String, KodikResult>{};
    for (var k in kodikResults) {
      final kodikTitles =
          [
            k.title,
            k.titleOrig,
            k.otherTitle,
          ].where((t) => t.isNotEmpty).map(_normalizeTitle).toList();

      for (var title in kodikTitles) {
        kodikTitleMap[title] = k;
      }
    }

    for (var anime in anilibriaAnimes) {
      final names =
          [
                anime.release.names.main,
                anime.release.names.english,
                anime.release.names.alternative,
              ]
              .where((n) => n != null && n.isNotEmpty)
              .map(_normalizeTitle)
              .toList();

      KodikResult? matchedKodik;
      for (var name in names) {
        if (kodikTitleMap.containsKey(name)) {
          matchedKodik = kodikTitleMap[name];
          break;
        }
      }

      if (matchedKodik != null) {
        matchedReleases.add(Anime.fromAnilibriaAndKodik(matchedKodik, anime));
        matchedKodikIds.add(matchedKodik.id);
      } else {
        matchedReleases.add(anime);
      }
    }

    final remainingKodik =
        kodikResults.where((k) => !matchedKodikIds.contains(k.id)).toList();

    return MatchResult(matchedReleases, remainingKodik);
  }
}

class MatchResult {
  final List<Anime> matched;
  final List<KodikResult> unmatched;

  MatchResult(this.matched, this.unmatched);
}
