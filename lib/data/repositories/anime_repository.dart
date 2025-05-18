import 'dart:developer';
import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/anime_release.dart';
import 'package:anime_app/data/models/franchise.dart';
import 'package:anime_app/data/models/kodik_result.dart';
import 'package:anime_app/data/repositories/base_repository.dart';
import 'package:anime_app/data/services/dio_client.dart';

class AnimeRepository extends BaseRepository {
  AnimeRepository() : super(DioClient().dio);

  Future<List<AnimeRelease>> searchAnime(String query) async {
    try {
      final anilibriaResponse = await dio.get(
        'app/search/releases?query=$query',
      );
      final anilibriaData = anilibriaResponse.data as List<dynamic>;
      final anilibriaReleases =
          anilibriaData.map((json) => AnimeRelease.fromJson(json)).toList();

      final kodikResults = await searchKodik(query);

      final matchedReleases = <AnimeRelease>[];
      final matchedKodikIds = <String>{};

      for (var release in anilibriaReleases) {
        final names =
            [
              release.names.main,
              release.names.english,
            ].where((n) => n.isNotEmpty).toList();
        if (release.names.alternative != null)
          names.add(release.names.alternative!);
        KodikResult? matchedKodik;
        for (var name in names) {
          for (var k in kodikResults) {
            if (k.title == name ||
                k.titleOrig == name ||
                k.otherTitle == name) {
              matchedKodik = k;
              break;
            }
          }
          if (matchedKodik != null) break;
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

      final movieReleases =
          movieResults.map((m) => AnimeRelease.fromKodik(m)).toList();

      final seriesReleases =
          seriesGroups.entries.map((entry) {
            final representative = entry.value.first;
            return AnimeRelease.fromKodik(representative);
          }).toList();

      return [...matchedReleases, ...movieReleases, ...seriesReleases];
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
      rethrow;
    }
  }

  Future<Anime> getAnimeById(int id) async {
    try {
      final response = await dio.get('anime/releases/$id');
      final data = response.data;

      log(data.toString());

      final anime = Anime.fromJson(data);

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
}
