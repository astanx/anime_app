import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/timecode.dart';
import 'package:anime_app/data/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoControllerProvider extends ChangeNotifier {
  VideoPlayerController? _controller;
  int _episodeIndex = 0;
  Anime? _anime;
  List<Timecode> _timecodes = [];
  Duration animeTimecode = Duration(seconds: 0);

  VideoPlayerController? get controller => _controller;
  int get episodeIndex => _episodeIndex;
  Anime? get anime => _anime;

  Future<void> loadEpisode(Anime anime, int index) async {
    _anime = anime;
    _episodeIndex = index;
    await fetchTimecodes();

    final episode = anime.episodes[index];
    final videoUrl = Uri.parse(
      episode.hls1080.isNotEmpty ? episode.hls1080 : episode.hls720,
    );

    await _controller?.dispose();
    _controller = VideoPlayerController.networkUrl(videoUrl);
    await _controller!.initialize();

    animeTimecode = Duration(seconds: getTimecode());
    if (animeTimecode.inSeconds > 0) {
      await _controller!.seekTo(animeTimecode);
    }

    _controller!.addListener(_notify);
    notifyListeners();
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

  void _notify() {
    notifyListeners();
  }

  @override
  void dispose() {
    _saveTimecode();
    _controller?.dispose();
    super.dispose();
  }

  int getTimecode() {
    return _timecodes
        .firstWhere(
          (t) => t.releaseEpisodeId == _anime!.episodes[_episodeIndex].id,
          orElse:
              () => Timecode(
                time: 0,
                isWatched: false,
                releaseEpisodeId: _anime!.episodes[_episodeIndex].id,
              ),
        )
        .time;
  }

  Future<void> fetchTimecodes() async {
    if (_timecodes.isEmpty) {
      _timecodes = await UserRepository().getTimecodes();
    }
  }

  void _saveTimecode() {
    if (_controller == null || _anime == null) return;

    final time = _controller!.value.position;
    final timecode = Timecode(
      time: time.inSeconds,
      releaseEpisodeId: _anime!.episodes[_episodeIndex].id,
      isWatched: true,
    );
    UserRepository().updateTimecode([timecode]);

    _timecodes.add(timecode);
  }
}
