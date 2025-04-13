import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/timecode.dart';
import 'package:anime_app/data/provider/timecode_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoControllerProvider extends ChangeNotifier {
  VideoPlayerController? _controller;
  int _episodeIndex = 0;
  Anime? _anime;
  BuildContext? _context;

  VideoPlayerController? get controller => _controller;
  int get episodeIndex => _episodeIndex;
  Anime? get anime => _anime;
  double _playbackSpeed = 1.0;

  double get playbackSpeed => _playbackSpeed;

  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed;
    _controller?.setPlaybackSpeed(speed);
    notifyListeners();
  }

  Future<void> loadEpisode(Anime anime, int index, BuildContext context) async {
    _anime = anime;
    _episodeIndex = index;
    _context = context;

    final timecodeProvider = Provider.of<TimecodeProvider>(
      context,
      listen: false,
    );
    final episode = anime.episodes[index];
    final timecode = timecodeProvider.getTimecodeForEpisode(episode.id);

    await timecodeProvider.fetchTimecodes();

    final videoUrl = Uri.parse(
      episode.hls1080.isNotEmpty ? episode.hls1080 : episode.hls720,
    );

    await _controller?.dispose();
    _controller = VideoPlayerController.networkUrl(videoUrl);
    await _controller!.initialize();
    _controller!.setPlaybackSpeed(_playbackSpeed);

    if (timecode > 0) {
      await _controller!.seekTo(Duration(seconds: timecode));
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

  void _notify() => notifyListeners();

  @override
  void dispose() {
    _saveTimecode();
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
