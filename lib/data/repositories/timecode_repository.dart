import 'package:anime_app/data/models/timecode.dart';
import 'package:anime_app/data/repositories/base_repository.dart';
import 'package:anime_app/data/services/dio_client.dart';

class TimecodeRepository extends BaseRepository {
  TimecodeRepository() : super(DioClient().dio);
  Future<void> updateTimecode(List<Timecode> timecodes) async {
    try {
      final body = timecodes.map((t) => t.toJson()).toList();

      await dio.post('accounts/users/me/views/timecodes', data: body);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Timecode>> getTimecodes() async {
    try {
      final response = await dio.get('accounts/users/me/views/timecodes');
      final data = response.data as List<dynamic>;

      final timecodes =
          data.map((t) => Timecode.fromJsonList(t as List)).toList();
      return timecodes;
    } catch (e) {
      rethrow;
    }
  }

  Future<Timecode> getTimecodeForEpisode(String episodeId) async {
    try {
      final response = await dio.get(
        'anime/releases/episodes/$episodeId/timecode',
      );
      final data = response.data as Map<String, dynamic>;
      return Timecode.fromJsonMap(data);
    } catch (e) {
      rethrow;
    }
  }
}
