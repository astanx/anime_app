import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/history.dart';
import 'package:anime_app/data/models/kodik_result.dart';
import 'package:anime_app/data/models/timecode.dart';
import 'package:anime_app/data/provider/history_provider.dart';
import 'package:anime_app/data/provider/timecode_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoControllerProvider extends ChangeNotifier {
  VideoPlayerController? _controller;
  int? _episodeIndex;
  Anime? _anime;
  KodikResult? _kodikResult;
  TimecodeProvider? _timecodeProvider;
  HistoryProvider? _historyProvider;
  double desiredPosition = 0.0;
  bool isDragging = false;
  bool isReversedTimer = true;
  bool _isDisposing = false;
  bool _wasStarted = false;
  Duration? openingStart;
  Duration? openingEnd;
  Duration? endingStart;
  Duration? endingEnd;
  String? hls1080;
  String? hls720;
  String? hls480;
  String? currentQuality;
  VideoPlayerController? get controller => _controller;
  int? get episodeIndex => _episodeIndex;
  Anime? get anime => _anime;
  KodikResult? get kodikResult => _kodikResult;
  List<String> qualities = [];
  List<double> playbackSpeeds = [0.5, 1.0, 1.25, 1.5, 2.0];

  void updateIsDragging(bool dragging) {
    isDragging = dragging;
    notifyListeners();
  }

  void updateDesiredPosition(double position) {
    desiredPosition = position;
    notifyListeners();
  }

  void reverseTimer() {
    isReversedTimer = !isReversedTimer;
    notifyListeners();
  }

  void seekForward() {
    final position =
        isDragging
            ? Duration(seconds: desiredPosition.toInt())
            : controller?.value.position ?? Duration.zero;
    final seekPos =
        position + const Duration(seconds: 10) < controller!.value.duration
            ? position + const Duration(seconds: 10)
            : controller!.value.duration;
    seek(seekPos);
  }

  void _updateDraggingState() {
    if (_controller == null || !_controller!.value.isInitialized) return;

    final currentPosition = _controller!.value.position.inSeconds.toDouble();

    if (isDragging) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final isDragging = (currentPosition - desiredPosition).abs() > 2.0;
        if (isDragging != isDragging) {
          updateIsDragging(isDragging);
        }

        if (!isDragging) {
          updateDesiredPosition(currentPosition);
        }
      });
    }
  }

  void seekBackward() {
    final position =
        isDragging
            ? Duration(seconds: desiredPosition.toInt())
            : controller?.value.position ?? Duration.zero;
    final seekPos =
        position - const Duration(seconds: 10) > Duration.zero
            ? position - const Duration(seconds: 10)
            : Duration.zero;
    seek(seekPos);
  }

  Future<void> loadEpisode(
    Anime anime,
    int index,
    BuildContext context,
    KodikResult? kodikResult,
  ) async {
    _saveTimecode();
    _anime = anime;
    _episodeIndex = index;
    _kodikResult = kodikResult;
    _wasStarted = false;
    isDragging = false;
    desiredPosition = 0.0;
    _timecodeProvider = Provider.of<TimecodeProvider>(context, listen: false);
    _historyProvider = Provider.of<HistoryProvider>(context, listen: false);

    final episode = anime.episodes[index];
    final timecode = await _timecodeProvider!.getTimecodeForEpisode(episode.id);
    if (episode.hls1080 != null) {
      hls1080 = episode.hls1080;
      qualities.add('1080');
    }
    if (episode.hls720 != null) {
      hls720 = episode.hls720;
      qualities.add('720');
    }
    qualities.add('480');
    hls480 = episode.hls480;
    final videoUrl = Uri.parse(hls1080 ?? hls720 ?? hls480!);
    currentQuality =
        hls1080 != null
            ? '1080'
            : hls720 != null
            ? '720'
            : '480';
    await _controller?.dispose();
    _controller = VideoPlayerController.networkUrl(
      videoUrl,
      videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true),
    );
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
    controller?.addListener(_updateDraggingState);
    notifyListeners();
  }

  Future<void> changeQuality(String quality) async {
    if (_controller == null ||
        anime == null ||
        quality.isEmpty ||
        _episodeIndex == null ||
        currentQuality == quality)
      return;
    Uri videoUrl;
    _saveTimecode();
    await _controller?.dispose();
    if (quality == '1080' && hls1080 != null) {
      videoUrl = Uri.parse(hls1080!);
      currentQuality = '1080';
    } else if (quality == '720' && hls720 != null) {
      videoUrl = Uri.parse(hls720!);
      currentQuality = '720';
    } else {
      videoUrl = Uri.parse(hls480!);
      currentQuality = '480';
    }
    final episode = anime!.episodes[_episodeIndex!];
    final timecode = await _timecodeProvider!.getTimecodeForEpisode(episode.id);
    _controller = VideoPlayerController.networkUrl(
      videoUrl,
      videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true),
    );

    await _controller!.initialize();
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
      if (!_wasStarted) {
        _wasStarted = true;
      }
    }
    _saveTimecode();
    notifyListeners();
  }

  void seek(Duration position) {
    updateIsDragging(true);
    updateDesiredPosition(position.inSeconds.toDouble());
    _controller?.seekTo(position);
    notifyListeners();
  }

  void _notify() => notifyListeners();

  @override
  void dispose() {
    _isDisposing = true;
    _saveTimecode();
    _controller?.removeListener(_notify);
    controller?.removeListener(_updateDraggingState);

    _controller?.dispose();
    super.dispose();
  }

  void _saveTimecode() {
    if (_controller == null ||
        _anime == null ||
        _timecodeProvider == null ||
        _historyProvider == null ||
        _episodeIndex == null ||
        !_wasStarted) {
      return;
    }

    final time = _controller!.value.position;
    if (time > Duration.zero) {
      final episodeId = _anime!.episodes[_episodeIndex!].id;
      final timecode = Timecode(
        time: time.inSeconds,
        releaseEpisodeId: episodeId,
        isWatched:
            time >=
            Duration(
              seconds:
                  _anime!.episodes[_episodeIndex!].ending?.start ??
                  _anime!.episodes[_episodeIndex!].duration - 60,
            ),
      );

      _timecodeProvider!.updateTimecode(timecode, notify: !_isDisposing);
      final history = AnimeWithHistory(
        anime: _anime!,
        lastWatchedEpisode: _episodeIndex!,
        isWatched:
            time >=
            Duration(
              seconds:
                  _anime!.episodes[_episodeIndex!].ending?.start ??
                  _anime!.episodes[_episodeIndex!].duration - 60,
            ),
        kodikResult: _kodikResult,
      );

      _historyProvider!.updateHistory(history);
    }
  }
}
