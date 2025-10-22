import 'dart:developer';

import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/timecode.dart';
import 'package:anime_app/data/repositories/base_repository.dart';
import 'package:anime_app/data/services/dio_client.dart';

class TimecodeRepository extends BaseRepository {
  TimecodeRepository() : super(DioClient().dio);
  Future<void> updateTimecode(Timecode timecode) async {
    try {
      final body = {
        'episode_id': timecode.episodeID,
        'is_watched': timecode.isWatched,
        'time': timecode.time,
        'anime_id': timecode.animeID,
      };

      await dio.post('/timecode', data: body);
    } catch (e) {
      log(e.toString());
    }
  }

  Future<Timecode> getTimecodeForEpisode(String episodeID, Anime anime) async {
    try {
      final response = await dio.get('/timecode?episodeID=$episodeID');
      final data = response.data as Map<String, dynamic>;
      return Timecode.fromJson(data);
    } catch (e) {
      return Timecode(
        episodeID: episodeID,
        time: 0,
        isWatched: false,
        animeID: anime.id,
      );
    }
  }

  Future<List<Timecode>> getTimecodesForAnime(String animeID) async {
    try {
      final response = await dio.get('/timecode/anime?animeID=$animeID');
      final data = response.data;
      return Timecode.fromJsonList(data);
    } catch (e) {
      return [];
    }
  }
}
