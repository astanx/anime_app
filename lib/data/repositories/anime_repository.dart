import 'dart:developer';
import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/episode.dart';
import 'package:anime_app/data/models/genre.dart';
import 'package:anime_app/data/models/mode.dart';
import 'package:anime_app/data/models/search_anime.dart';
import 'package:anime_app/data/repositories/base_repository.dart';
import 'package:anime_app/data/services/dio_client.dart';

class AnimeRepository extends BaseRepository {
  AnimeRepository({required this.mode}) : super(DioClient().dio);
  Mode mode;

  Future<List<SearchAnime>> searchAnime(String query) async {
    try {
      final response = await dio.get('/anime/${mode.name}?query=$query');
      final data = response.data;
      final anime = SearchAnime.fromListJson(data);
      return anime;
    } catch (e) {
      log('Error searching anime: $e');
      rethrow;
    }
  }

  Future<List<SearchAnime>> getRecommendedAnime() async {
    try {
      final response = await dio.get(
        '/anime/${mode.name}/recommended?limit=14',
      );
      final data = response.data;

      final anime = SearchAnime.fromListJson(data);

      return anime;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Genre>> getGenres() async {
    try {
      final response = await dio.get('/anime/${mode.name}/genres');
      final data = response.data;

      final genres = Genre.fromListJson(data);

      return genres;
    } catch (e) {
      rethrow;
    }
  }

  Future<Anime> getAnimeById(String id) async {
    try {
      final isNumeric = int.tryParse(id) != null;

      final endpoint =
          isNumeric
              ? '/anime/${Mode.anilibria.name}/$id'
              : '/anime/${Mode.consumet.name}/$id';

      final response = await dio.get(endpoint);
      final data = response.data;
      final anime = Anime.fromJsonPreview(data);
      return anime;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SearchAnime>> getLatestReleases() async {
    try {
      final response = await dio.get('/anime/${mode.name}/latest?limit=14');
      final data = response.data;

      final anime = SearchAnime.fromListJson(data);

      return anime;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SearchAnime>> getGenreReleases(String genre) async {
    try {
      final response = await dio.get(
        '/anime/${mode.name}/genre/releases?genre=$genre',
      );
      final data = response.data;

      final releases = SearchAnime.fromListJson(data);

      return releases;
    } catch (e) {
      rethrow;
    }
  }

  Future<Anime> getAnimeInfo(String id) async {
    try {
      final response = await dio.get('/anime/${mode.name}/$id');
      final data = response.data;

      final anime = Anime.fromJsonPreview(data);

      return anime;
    } catch (e) {
      rethrow;
    }
  }

  Future<Episode> getEpisodeInfo(
    PreviewEpisode episodeInfo, [
    Anime? anime,
  ]) async {
    try {
      if (anime != null) {
        final episode =
            anime.episodes.where((e) => e.id == episodeInfo.id).firstOrNull;
        if (episode != null) {
          return episode;
        }
      }
      final response = await dio.get(
        '/anime/${mode.name}/episode/${episodeInfo.id}?title=${episodeInfo.title}&ordinal=${episodeInfo.ordinal}',
      );
      final data = response.data;

      final episode = Episode.fromJson(data);
      anime!.episodes.add(episode);

      return episode;
    } catch (e) {
      rethrow;
    }
  }
}
