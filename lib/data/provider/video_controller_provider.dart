import 'dart:convert';

import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/anime_mode.dart';
import 'package:anime_app/data/models/episode.dart';
import 'package:anime_app/data/models/mode.dart';
import 'package:anime_app/data/models/history.dart';
import 'package:anime_app/data/models/timecode.dart';
import 'package:anime_app/data/provider/history_provider.dart';
import 'package:anime_app/data/provider/timecode_provider.dart';
import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/data/storage/anime_mode_storage.dart';
import 'package:anime_app/data/storage/subtitle_storage.dart';
import 'package:anime_app/data/storage/translate_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:charset_converter/charset_converter.dart';

class SubtitleCue {
  final Duration startTime;
  final Duration endTime;
  final String text;

  SubtitleCue({
    required this.startTime,
    required this.endTime,
    required this.text,
  });

  SubtitleCue copyWith({String? text}) {
    return SubtitleCue(
      text: text ?? this.text,
      startTime: startTime,
      endTime: endTime,
    );
  }
}

class VideoControllerProvider extends ChangeNotifier {
  final Mode mode;

  late final AnimeRepository _animeRepository;

  VideoControllerProvider({required this.mode}) {
    _animeRepository = AnimeRepository(mode: mode);
  }

  VideoPlayerController? _controller;
  int? _episodeIndex;
  Anime? _anime;
  String? episodeID;
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
  String? currentQuality;
  VideoPlayerController? get controller => _controller;
  int? get episodeIndex => _episodeIndex;
  Anime? get anime => _anime;
  get saveTimecode => _saveTimecode;
  List<String> qualities = [];
  List<double> playbackSpeeds = [0.5, 1.0, 1.25, 1.5, 2.0];
  bool? _isDubbedMode;
  bool get isDubbedMode => _isDubbedMode ?? false;

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
        final draggingState = (currentPosition - desiredPosition).abs() > 2.0;
        if (isDragging != draggingState) {
          updateIsDragging(draggingState);
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

  bool _sawDubSubTutorial = true;
  bool get sawDubSubTutorial => _sawDubSubTutorial;

  void changeSubDubTutorial(bool value) {
    _sawDubSubTutorial = value;
    notifyListeners();
  }

  void toggleDubbed() {
    _isDubbedMode = !(_isDubbedMode ?? true);
    AnimeModeStorage.saveMode(
      _isDubbedMode ?? false ? AnimeMode.dub : AnimeMode.sub,
    );
    notifyListeners();
  }

  Future<void> loadEpisode(Anime anime, int index, BuildContext context) async {
    _saveTimecode(true);
    _anime = anime;
    qualities = [];
    subtitlesLanguages = {};
    _episodeIndex = index;
    _lastSaved = Duration.zero;
    _wasStarted = false;
    isDragging = false;
    desiredPosition = 0.0;
    _timecodeProvider ??= Provider.of<TimecodeProvider>(context, listen: false);
    _historyProvider ??= Provider.of<HistoryProvider>(context, listen: false);
    _timecodeProvider!.fetchTimecodesForAnime(anime.id);
    episodeID = anime.previewEpisodes[index].id;
    _isDubbedMode ??= await AnimeModeStorage.getMode() == AnimeMode.dub;
    Episode episode;
    try {
      episode = anime.episodes.firstWhere(
        (e) => e.id == episodeID && e.isDubbed == _isDubbedMode,
      );
    } catch (e) {
      episode = await _animeRepository.getEpisodeInfo(
        anime.previewEpisodes[index],
        anime.previewEpisodes[index].isDubbed ? _isDubbedMode! : false,
        anime,
      );
    }

    final timecode = await _timecodeProvider!.getTimecodeForEpisode(
      episode.id,
      anime,
    );
    if (anime.previewEpisodes[index].isSubbed) {
      vttUrls = episode.subtitles;
      await loadSubtitles();
    }

    for (var source in episode.sources) {
      qualities.add(source.type);
    }

    final videoUrl = Uri.parse(episode.sources.first.url);
    currentQuality = episode.sources.first.type;
    await _controller?.dispose();
    _controller = VideoPlayerController.networkUrl(
      videoUrl,
      videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true),
    );
    await _controller!.initialize();

    if (timecode > 0) {
      await _controller!.seekTo(Duration(seconds: timecode));
    }

    openingStart = Duration(seconds: episode.opening.start);
    endingStart =
        episode.ending.start != 0
            ? Duration(seconds: episode.ending.start)
            : null;

    openingEnd =
        episode.opening.end != 0
            ? Duration(seconds: episode.opening.end)
            : null;
    endingEnd =
        episode.ending.end != 0 ? Duration(seconds: episode.ending.end) : null;

    _sawDubSubTutorial = await AnimeModeStorage.getSawDubSubTutorial();

    _controller!.addListener(_notify);
    _controller!.addListener(autoSaveTimecode);
    _controller?.addListener(_updateDraggingState);
    _controller?.addListener(preventComplete);
    notifyListeners();
  }

  Future<void> changeQuality(String type) async {
    if (_controller == null ||
        anime == null ||
        type.isEmpty ||
        _episodeIndex == null ||
        currentQuality == type) {
      return;
    }
    Uri videoUrl;
    _saveTimecode();
    await _controller?.dispose();
    final episode = anime!.episodes[_episodeIndex!];
    final s = episode.sources.firstWhere((s) => s.type == type);
    videoUrl = Uri.parse(s.url);
    currentQuality = s.type;
    final timecode = await _timecodeProvider!.getTimecodeForEpisode(
      episode.id,
      anime!,
    );
    _controller = VideoPlayerController.networkUrl(
      videoUrl,
      videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true),
    );

    await _controller!.initialize();
    if (timecode > 0) {
      await _controller!.seekTo(Duration(seconds: timecode));
    }
    _controller!.addListener(_notify);
    _controller!.addListener(autoSaveTimecode);
    _controller?.addListener(_updateDraggingState);
    _controller?.addListener(preventComplete);

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
    _saveTimecode(true);
    notifyListeners();
  }

  void seek(Duration position) async {
    updateIsDragging(true);
    updateDesiredPosition(position.inSeconds.toDouble());

    if (_controller!.value.duration - position < Duration(milliseconds: 500))
      _controller?.seekTo(position - Duration(milliseconds: 500));
    else
      _controller?.seekTo(position);

    notifyListeners();
  }

  void _notify() => notifyListeners();

  Timecode _previousTimecode = Timecode(
    animeID: '',
    episodeID: '',
    time: 0,
    isWatched: false,
  );

  void autoSaveTimecode() {
    if (_controller!.value.isInitialized &&
        _controller!.value.isPlaying &&
        !_isDisposing) {
      _saveTimecode();
    }
  }

  void preventComplete() async {
    if (_controller!.value.duration - _controller!.value.position <
        Duration(milliseconds: 500)) {
      await _controller!.pause();
    }
  }

  @override
  void dispose() {
    _isDisposing = true;
    _saveTimecode(true);
    _controller?.removeListener(_notify);
    _controller?.removeListener(autoSaveTimecode);
    controller?.removeListener(_updateDraggingState);
    _controller?.removeListener(preventComplete);

    _controller?.dispose();
    super.dispose();
  }

  Duration _lastSaved = Duration.zero;

  void _saveTimecode([bool forceSave = false]) {
    if (_controller == null ||
        _anime == null ||
        _timecodeProvider == null ||
        _historyProvider == null ||
        _episodeIndex == null ||
        episodeID == null ||
        !_wasStarted) {
      return;
    }

    if (_previousTimecode.time >= _controller!.value.position.inSeconds - 1 &&
        _previousTimecode.episodeID == episodeID) {
      return;
    }

    final time = _controller!.value.position;
    final duration = _controller!.value.duration;
    if (time > Duration.zero) {
      final isWatched =
          (endingStart != null && time >= endingStart!) ||
          (time >= duration - const Duration(seconds: 5));
      if ((time - _lastSaved).inSeconds < 10 && !forceSave && !isWatched)
        return;
      _lastSaved = time;

      final episode = _anime!.episodes.where((e) => e.id == episodeID!).first;
      final timecode = Timecode(
        animeID: _anime!.id,
        time: time.inSeconds,
        episodeID: episodeID!,
        isWatched:
            time >=
            (episode.ending.start != 0
                ? Duration(seconds: episode.ending.start)
                : controller!.value.duration - Duration(seconds: 60)),
      );

      _timecodeProvider!.updateTimecode(timecode, notify: !_isDisposing);
      final history = AnimeWithHistory(
        anime: _anime!,
        history: History(
          animeID: _anime!.id,
          watchedAt: DateTime.now(),
          lastWatchedEpisode: _episodeIndex!,
          isWatched: isWatched,
        ),
      );

      _historyProvider!.addOrUpdateHistory(history);
    }
  }

  List<SubtitleCue> _subtitles = [];
  Set<String> subtitlesLanguages = {};
  String? currentLanguage;
  List<Subtitle>? vttUrls = [];

  List<SubtitleCue> get subtitles => _subtitles;
  SubtitleStorage subtitleStorage = SubtitleStorage();
  String translationLanguage = '';

  Future<void> loadSubtitles() async {
    if (vttUrls != null && vttUrls!.isEmpty) {
      _subtitles = [];
      notifyListeners();
      return;
    }
    if (translationLanguage.isEmpty) {
      translationLanguage = await TranslateStorage().getLanguage() ?? '';
    }
    currentLanguage ??= await subtitleStorage.getLanguage() ?? 'English';
    for (var vtt in vttUrls!) {
      if (vtt.language == 'thumbnails') continue;
      subtitlesLanguages.add(vtt.language);
    }

    try {
      final response = await http.get(
        Uri.parse(
          vttUrls!.firstWhere((vtt) => vtt.language == currentLanguage).vtt,
        ),
      );
      var body = '';
      try {
        body = utf8.decode(response.bodyBytes);
      } catch (_) {
        body = await CharsetConverter.decode(
          'windows-1256',
          response.bodyBytes,
        ).catchError((_) => '');
      }
      _subtitles = _parseVtt(body);
      notifyListeners();
    } catch (e) {
      _subtitles = [];
      notifyListeners();
    }
  }

  Future<void> changeLanguage(String language) async {
    currentLanguage = language;
    subtitlesLanguages = {};
    await loadSubtitles();
    await subtitleStorage.saveLanguage(language);
  }

  List<SubtitleCue> _parseVtt(String vttContent) {
    final List<SubtitleCue> cues = [];
    final lines = vttContent.split('\n');
    bool isCue = false;
    Duration? startTime, endTime;
    String text = '';

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) {
        if (isCue && startTime != null && endTime != null && text.isNotEmpty) {
          cues.add(
            SubtitleCue(startTime: startTime, endTime: endTime, text: text),
          );
          isCue = false;
          text = '';
        }
        continue;
      }

      if (line.contains('-->')) {
        isCue = true;
        final times = line.split('-->');
        startTime = _parseDuration(times[0].trim());
        endTime = _parseDuration(times[1].trim());
      } else if (isCue && line != 'WEBVTT') {
        text += (text.isEmpty ? '' : '\n') + line;
      }
    }

    if (isCue && startTime != null && endTime != null && text.isNotEmpty) {
      cues.add(SubtitleCue(startTime: startTime, endTime: endTime, text: text));
    }

    return cues;
  }

  Duration _parseDuration(String time) {
    time = time.trim();
    final parts = time.split(':');
    int hours = 0;
    int minutes = 0;
    int seconds = 0;
    int milliseconds = 0;

    try {
      if (parts.length == 3) {
        hours = int.parse(parts[0]);
        minutes = int.parse(parts[1]);
        final secondsPart = parts[2].split('.');
        seconds = int.parse(secondsPart[0]);
        milliseconds = secondsPart.length > 1 ? int.parse(secondsPart[1]) : 0;
      } else if (parts.length == 2) {
        minutes = int.parse(parts[0]);
        final secondsPart = parts[1].split('.');
        seconds = int.parse(secondsPart[0]);
        milliseconds = secondsPart.length > 1 ? int.parse(secondsPart[1]) : 0;
      } else {
        throw FormatException('Invalid time format: $time');
      }
    } catch (e) {
      return Duration.zero;
    }

    return Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: milliseconds,
    );
  }
}
