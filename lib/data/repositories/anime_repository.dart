import 'dart:developer';
import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/anime_release.dart';
import 'package:anime_app/data/repositories/base_repository.dart';
import 'package:anime_app/data/services/dio_client.dart';

class AnimeRepository extends BaseRepository {
  AnimeRepository() : super(DioClient().dio);

  Future<Anime> getAnimeById(int id) async {
    try {
      log('$id');
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
      final response = await dio.get('anime/releases/latest?limit$limit');
      final data = response.data as List<dynamic>;

      log(data.toString());

      final releases = data.map((json) => AnimeRelease.fromJson(json)).toList();

      return releases;
    } catch (e) {
      rethrow;
    }
  }
}
