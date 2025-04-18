import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/history.dart';
import 'package:anime_app/data/models/timecode.dart';
import 'package:anime_app/data/provider/timecode_provider.dart';
import 'package:anime_app/data/storage/history_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoControllerProvider extends ChangeNotifier {
  VideoPlayerController? _controller;
  int _episodeIndex = 0;
  Anime? _anime;
  BuildContext? _context;
  Duration? openingStart;
  Duration? openingEnd;
  Duration? endingStart;
  Duration? endingEnd;

  VideoPlayerController? get controller => _controller;
  int get episodeIndex => _episodeIndex;
  Anime? get anime => _anime;

  Future<void> loadEpisode(Anime anime, int index, BuildContext context) async {
    _anime = anime;
    _episodeIndex = index;
    _context = context;

    final timecodeProvider = Provider.of<TimecodeProvider>(
      context,
      listen: false,
    );

    await timecodeProvider.fetchTimecodes();
    final episode = anime.episodes[index];
    final timecode = timecodeProvider.getTimecodeForEpisode(episode.id);

    final videoUrl = Uri.parse(
      episode.hls1080.isNotEmpty ? episode.hls1080 : episode.hls720,
    );

    await _controller?.dispose();
    _controller = VideoPlayerController.networkUrl(videoUrl);
    await _controller!.initialize();

    if (timecode > 0) {
      await _controller!.seekTo(Duration(seconds: timecode));
    }

    openingStart =
        episode.opening?.start != null
            ? Duration(seconds: episode.opening!.start!)
            : null;
    endingStart =
        episode.ending?.start != null
            ? Duration(seconds: episode.ending!.start!)
            : null;

    openingEnd =
        episode.opening?.stop != null
            ? Duration(seconds: episode.opening!.stop!)
            : null;
    endingEnd =
        episode.ending?.stop != null
            ? Duration(seconds: episode.ending!.stop!)
            : null;

    _controller!.addListener(_notify);
    notifyListeners();

    final history = History(
      animeId: anime.release.id,
      lastWatchedEpisode: index,
    );

    HistoryStorage.updateHistory(history);
  }

  void togglePlayPause() {
    if (_controller?.value.isPlaying ?? false) {
      _controller?.pause();
    } else {
      _controller?.play();
    }
    notifyListeners();
  }

  void seek(Duration position) {
    _controller?.seekTo(position);
    notifyListeners();
  }

  void _notify() => notifyListeners();

  @override
  void dispose() {
    _saveTimecode();
    _controller?.removeListener(_notify);
    _controller?.dispose();
    super.dispose();
  }

  void _saveTimecode() {
    if (_controller == null || _anime == null || _context == null) return;

    final time = _controller!.value.position;
    final episodeId = _anime!.episodes[_episodeIndex].id;
    final timecode = Timecode(
      time: time.inSeconds,
      releaseEpisodeId: episodeId,
      isWatched: true,
    );

    Provider.of<TimecodeProvider>(
      _context!,
      listen: false,
    ).updateTimecode(timecode);
  }
}
