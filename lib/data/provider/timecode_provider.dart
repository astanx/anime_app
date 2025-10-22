import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/timecode.dart';
import 'package:anime_app/data/repositories/timecode_repository.dart';
import 'package:flutter/material.dart';

class TimecodeProvider extends ChangeNotifier {
  final List<Timecode> _timecodes = [];
  final _repository = TimecodeRepository();

  List<Timecode> get timecodes => _timecodes;

  Future<int> getTimecodeForEpisode(String episodeID, Anime anime) async {
    try {
      final timecode = _timecodes.firstWhere((t) => t.episodeID == episodeID);
      return timecode.time;
    } catch (e) {
      final timecode = await _repository.getTimecodeForEpisode(
        episodeID,
        anime,
      );
      if (timecode.time > 0) {
        _timecodes.add(timecode);
      }
      return timecode.time;
    }
  }

  Future<void> updateTimecode(Timecode timecode, {bool notify = false}) async {
    if (timecode.time > 0) {
      _repository.updateTimecode(timecode);
      final index = _timecodes.indexWhere(
        (t) => t.episodeID == timecode.episodeID,
      );
      if (index != -1) {
        _timecodes[index] = timecode;
      } else {
        _timecodes.add(timecode);
      }
      if (notify) {
        notifyListeners();
      }
    }
  }

  Future<void> fetchTimecodesForAnime(String animeID) async {
    final timecodes = await _repository.getTimecodesForAnime(animeID);
    _timecodes.addAll(timecodes);
    notifyListeners();
  }

  bool isWatched(String episodeId) {
    return _timecodes.any((el) => el.episodeID == episodeId);
  }
}
