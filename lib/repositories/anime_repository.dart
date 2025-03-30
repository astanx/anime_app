import 'dart:developer';

import 'package:anime_app/models/anime.dart';
import 'package:anime_app/repositories/base_repository.dart';
import 'package:dio/dio.dart';

class AnimeRepository extends BaseRepository {
  AnimeRepository(Dio dio) : super(dio);

  Future<Anime> getAnimeById(int id) async {
    try {
      final response = await dio.get('title?$id');
      final data = response.data;

      log(data.toString());

      final anime = Anime.fromJson(data);

      return anime;
    } catch (e) {
      rethrow;
    }
  }
}
