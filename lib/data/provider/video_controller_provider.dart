import 'package:anime_app/data/models/anime.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoControllerProvider extends ChangeNotifier {
  VideoPlayerController? _controller;
  int _episodeIndex = 0;
  Anime? _anime;

  VideoPlayerController? get controller => _controller;
  int get episodeIndex => _episodeIndex;
  Anime? get anime => _anime;

  Future<void> loadEpisode(Anime anime, int index) async {
    _anime = anime;
    _episodeIndex = index;
    final episode = anime.episodes[index];
    final videoUrl = Uri.parse(
      episode.hls1080.isNotEmpty ? episode.hls1080 : episode.hls720,
    );

    await _controller?.dispose();
    _controller = VideoPlayerController.networkUrl(videoUrl);
    await _controller!.initialize();
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
    _controller?.dispose();
    super.dispose();
  }
}
