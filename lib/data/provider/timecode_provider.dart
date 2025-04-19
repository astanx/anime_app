import 'package:anime_app/data/models/timecode.dart';
import 'package:anime_app/data/repositories/user_repository.dart';
import 'package:flutter/material.dart';

class TimecodeProvider extends ChangeNotifier {
  List<Timecode> _timecodes = [];
  bool _hasFetched = false;

  List<Timecode> get timecodes => _timecodes;

  Future<void> fetchTimecodes() async {
    if (!_hasFetched) {
      _timecodes = await UserRepository().getTimecodes();
      _hasFetched = true;
      notifyListeners();
    }
  }

  int getTimecodeForEpisode(String episodeId) {
    return _timecodes
        .firstWhere(
          (t) => t.releaseEpisodeId == episodeId,
          orElse:
              () => Timecode(
                time: 0,
                isWatched: false,
                releaseEpisodeId: episodeId,
              ),
        )
        .time;
  }

  Future<void> updateTimecode(Timecode timecode) async {
    if (timecode.time > 0) {
      UserRepository().updateTimecode([timecode]);
      final index = _timecodes.indexWhere(
        (t) => t.releaseEpisodeId == timecode.releaseEpisodeId,
      );
      if (index != -1) {
        _timecodes[index] = timecode;
      } else {
        _timecodes.add(timecode);
      }
      notifyListeners();
    }
  }
}
