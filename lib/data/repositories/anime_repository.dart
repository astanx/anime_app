import 'dart:developer';
import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/anime_release.dart';
import 'package:anime_app/data/models/franchise.dart';
import 'package:anime_app/data/repositories/base_repository.dart';
import 'package:anime_app/data/services/dio_client.dart';

class AnimeRepository extends BaseRepository {
  AnimeRepository() : super(DioClient().dio);

  Future<List<AnimeRelease>> searchAnime(String query) async {
    try {
      final response = await dio.get('app/search/releases?query=$query');
      final data = response.data as List<dynamic>;

      if (data.isNotEmpty) {
        final anime = data.map((json) => AnimeRelease.fromJson(json)).toList();
        return anime;
      } else {
        throw Exception('No anime found');
      }
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

  Future<List<Franchise>> getFranchiseById(String releaseId) async {
    try {
      final response = await dio.get('anime/franchises/release/$releaseId');
      final data = response.data as List<dynamic>;

      log(data.toString());

      final franchise = data.map((f) => Franchise.fromJson(f)).toList();

      return franchise;
    } catch (e) {
      rethrow;
    }
  }
}
