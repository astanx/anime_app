import 'dart:developer';

import 'package:anime_app/data/models/history.dart';
import 'package:anime_app/data/models/mode.dart';
import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/data/repositories/base_repository.dart';
import 'package:anime_app/data/services/dio_client.dart';

class HistoryRepository extends BaseRepository {
  final Mode mode;
  final AnimeRepository repository;

  HistoryRepository({required this.mode})
    : repository = AnimeRepository(mode: mode),
      super(DioClient().dio);

  Future<void> addToHistory(History history) async {
    try {
      final body = {
        'anime_id': history.animeID,
        'last_watched': history.lastWatchedEpisode,
        'is_watched': history.isWatched,
      };
      final response = await dio.post('/history', data: body);
      if (response.statusCode == 200) {
        return;
      }
      throw Error();
    } catch (e) {
      log(e.toString());
    }
  }

  Future<HistoryData> getHistory(int page, int limit) async {
    try {
      final response = await dio.get('/history?page=$page&limit=$limit');
      final data = response.data;
      final favourites = HistoryData.fromJson(data);

      return favourites;
    } catch (e) {
      rethrow;
    }
  }
}
