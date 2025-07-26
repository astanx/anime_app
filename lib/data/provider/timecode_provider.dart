import 'package:anime_app/data/models/timecode.dart';
import 'package:anime_app/data/repositories/timecode_repository.dart';
import 'package:flutter/material.dart';

class TimecodeProvider extends ChangeNotifier {
  List<Timecode> _timecodes = [];
  bool _hasFetched = false;
  final Map<int, bool> _hasFetchedForRelease = {};
  final _repository = TimecodeRepository();

  List<Timecode> get timecodes => _timecodes;

  Future<void> fetchTimecodes() async {
    if (!_hasFetched) {
      _timecodes = await _repository.getTimecodes();
      _hasFetched = true;
      notifyListeners();
    }
  }

  Future<int> getTimecodeForEpisode(String episodeId) async {
    try {
      final timecode = _timecodes.firstWhere(
        (t) => t.releaseEpisodeId == episodeId,
      );
      return timecode.time;
    } catch (e) {
      final timecode = await _repository.getTimecodeForEpisode(episodeId);
      _timecodes.add(timecode);
      return timecode.time;
    }
  }

  Future<void> fetchTimecodesForRelease(int releaseId) async {
    if (!(_hasFetchedForRelease[releaseId] ?? false)) {
      final timecodes = await _repository.getTimecodesForRelease(releaseId);
      _timecodes.addAll(timecodes);
      _hasFetchedForRelease[releaseId] = true;
      notifyListeners();
    }
  }

  Future<void> updateTimecode(Timecode timecode, {bool notify = true}) async {
    if (timecode.time > 0) {
      _repository.updateTimecode([timecode]);
      final index = _timecodes.indexWhere(
        (t) => t.releaseEpisodeId == timecode.releaseEpisodeId,
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

  bool isWatched(String episodeId) {
    return _timecodes.any((el) => el.releaseEpisodeId == episodeId);
  }
}
