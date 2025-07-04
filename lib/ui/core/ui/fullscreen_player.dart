import 'dart:async';
import 'dart:io';
import 'package:anime_app/data/models/kodik_result.dart';
import 'package:anime_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/provider/video_controller_provider.dart';

class FullscreenPlayer extends StatefulWidget {
  const FullscreenPlayer({
    super.key,
    required this.provider,
    required this.anime,
    required this.kodikResult,
  });
  final VideoControllerProvider provider;
  final Anime anime;
  final KodikResult? kodikResult;

  @override
  State<FullscreenPlayer> createState() => _FullscreenPlayerState();
}

class _FullscreenPlayerState extends State<FullscreenPlayer> {
  bool _showControls = true;
  bool _showSeekIcon = false;
  IconData _seekIcon = Icons.replay_10;
  Timer? _hideTimer;
  Timer? _displayTimer;
  bool isPipAvailable = false;
  static const pipChannel = MethodChannel('pip_channel');

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startHideTimer();
    _checkPipAvailability();
  }

  void _checkPipAvailability() {
    isPipAvailable = Platform.isAndroid || Platform.isIOS;
    setState(() {});
  }

  Future<void> _enablePip() async {
    try {
      await pipChannel.invokeMethod('enablePip');
    } on PlatformException catch (e) {
      print("Failed to enable PiP: '${e.message}'.");
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _startDisplayTimer() {
    _displayTimer?.cancel();
    _displayTimer = Timer(const Duration(seconds: 9), () {
      WakelockPlus.disable();
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return hours > 0
        ? '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}'
        : '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  void _handleDoubleTap(double xPosition, VideoControllerProvider provider) {
    final position = provider.controller?.value.position ?? Duration.zero;
    final screenWidth = MediaQuery.of(context).size.width;

    if (xPosition < screenWidth / 2) {
      provider.seek(position - const Duration(seconds: 10));
      setState(() {
        _seekIcon = Icons.replay_10;
        _showSeekIcon = true;
      });
    } else {
      provider.seek(position + const Duration(seconds: 10));
      setState(() {
        _seekIcon = Icons.forward_10;
        _showSeekIcon = true;
      });
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _showSeekIcon = false);
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: widget.provider,
      child: Consumer<VideoControllerProvider>(
        builder: (context, provider, _) {
          final controller = provider.controller;
          final episodeIndex = provider.episodeIndex;
          final anime = widget.anime;
          final kodikResult = widget.kodikResult;
          final position = controller?.value.position ?? Duration.zero;
          final duration = controller?.value.duration ?? Duration.zero;
          final buffered = controller?.value.buffered ?? [];

          final l10n = AppLocalizations.of(context);

          double bufferedEnd = buffered.fold<double>(
            0.0,
            (max, range) =>
                range.end.inMilliseconds > max
                    ? range.end.inMilliseconds.toDouble()
                    : max,
          );
          double bufferedValue =
              duration.inMilliseconds > 0
                  ? bufferedEnd / duration.inMilliseconds.toDouble()
                  : 0.0;
          return Scaffold(
            backgroundColor: Colors.black,
            body:
                episodeIndex == null
                    ? const Center(child: CircularProgressIndicator())
                    : Stack(
                      alignment: Alignment.center,
                      children: [
                        if (controller != null &&
                            controller.value.isInitialized)
                          Center(
                            child: AspectRatio(
                              aspectRatio: controller.value.aspectRatio,
                              child: VideoPlayer(controller),
                            ),
                          ),
                        if (controller == null ||
                            !controller.value.isInitialized)
                          const Center(child: CircularProgressIndicator()),
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              setState(() => _showControls = true);
                              _startHideTimer();
                            },
                            onDoubleTapDown:
                                (details) => _handleDoubleTap(
                                  details.globalPosition.dx,
                                  provider,
                                ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: AnimatedOpacity(
                            opacity: _showControls ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.black54, Colors.transparent],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    IconButton(
                                      onPressed:
                                          isPipAvailable ? _enablePip : null,
                                      icon: const Icon(
                                        Icons.picture_in_picture,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 24,
                          left: 16,
                          right: 16,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (provider.openingStart != null &&
                                        position >= provider.openingStart! &&
                                        position <=
                                            provider.openingStart! +
                                                const Duration(seconds: 20))
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                            179,
                                            158,
                                            158,
                                            158,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed:
                                            () => provider.seek(
                                              provider.openingEnd!,
                                            ),
                                        child: Text(
                                          l10n!.skip_opening,
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      )
                                    else
                                      const SizedBox.shrink(),
                                    if (episodeIndex <
                                                anime.episodes.length - 1 &&
                                            position == duration ||
                                        ((provider.endingStart != null &&
                                            position >= provider.endingStart! &&
                                            position <=
                                                provider.endingStart! +
                                                    const Duration(
                                                      seconds: 20,
                                                    ))))
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                            179,
                                            158,
                                            158,
                                            158,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed:
                                            duration ==
                                                        (provider.endingEnd ??
                                                            Duration(
                                                              seconds: 0,
                                                            )) ||
                                                    duration == position
                                                ? () {
                                                  provider.seek(
                                                    Duration(
                                                      seconds:
                                                          anime
                                                              .episodes[episodeIndex]
                                                              .duration,
                                                    ),
                                                  );
                                                  provider.loadEpisode(
                                                    anime,
                                                    episodeIndex + 1,
                                                    context,
                                                    kodikResult,
                                                  );
                                                }
                                                : () {
                                                  provider.seek(
                                                    Duration(
                                                      seconds:
                                                          anime
                                                              .episodes[episodeIndex]
                                                              .ending!
                                                              .stop!,
                                                    ),
                                                  );
                                                },
                                        child: Text(
                                          duration ==
                                                      (provider.endingEnd ??
                                                          Duration(
                                                            seconds: 0,
                                                          )) ||
                                                  duration == position
                                              ? l10n!.next_episode
                                              : l10n!.skip_ending,
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              AnimatedOpacity(
                                opacity: _showControls ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 300),
                                child: IgnorePointer(
                                  ignoring: !_showControls,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _formatDuration(position),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            ),
                                            Text(
                                              _formatDuration(duration),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        height: 24,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            LinearProgressIndicator(
                                              value: bufferedValue,
                                              backgroundColor: Colors.grey[800],
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.grey[600]!,
                                                  ),
                                              minHeight: 3,
                                            ),
                                            Slider(
                                              activeColor: Colors.white,
                                              inactiveColor: Colors.grey[600],
                                              value:
                                                  position.inSeconds.toDouble(),
                                              min: 0,
                                              max:
                                                  duration.inSeconds.toDouble(),
                                              onChanged: (value) {
                                                provider.seek(
                                                  Duration(
                                                    seconds: value.toInt(),
                                                  ),
                                                );
                                                _startHideTimer();
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_showSeekIcon)
                          Center(
                            child: Icon(
                              _seekIcon,
                              color: Colors.white.withOpacity(0.8),
                              size: 50,
                            ),
                          ),
                        AnimatedOpacity(
                          opacity: _showControls ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IgnorePointer(
                                  ignoring: !_showControls,
                                  child: IconButton(
                                    icon: const Icon(Icons.replay_10, size: 40),
                                    color: Colors.white,
                                    onPressed: () {
                                      provider.seek(
                                        position - const Duration(seconds: 10),
                                      );
                                      _startHideTimer();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 48),
                                Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      controller?.value.isPlaying ?? false
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      size: 44,
                                    ),
                                    color: Colors.white,
                                    onPressed: () {
                                      provider.togglePlayPause();
                                      if (controller?.value.isPlaying ??
                                          false) {
                                        _displayTimer?.cancel();
                                      } else {
                                        _startDisplayTimer();
                                      }
                                      setState(() => _showControls = true);
                                      _startHideTimer();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 48),
                                IgnorePointer(
                                  ignoring: !_showControls,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.forward_10,
                                      size: 40,
                                    ),
                                    color: Colors.white,
                                    onPressed: () {
                                      provider.seek(
                                        position + const Duration(seconds: 10),
                                      );
                                      _startHideTimer();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
          );
        },
      ),
    );
  }
}
