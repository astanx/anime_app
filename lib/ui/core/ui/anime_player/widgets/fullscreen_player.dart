import 'dart:async';
import 'dart:io';
import 'package:anime_app/data/models/kodik_result.dart';
import 'package:anime_app/l10n/app_localizations.dart';
import 'package:anime_app/ui/core/ui/anime_player/widgets/player_controls.dart';
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
    if (Platform.isAndroid) {
      isPipAvailable = true;
    } else if (Platform.isIOS) {
      isPipAvailable = false;
    } else {
      isPipAvailable = false;
    }
    setState(() {});
  }

  Future<void> _enablePip(VideoControllerProvider provider) async {
    if (!isPipAvailable) return;
    try {
      await pipChannel.invokeMethod('enablePip', {
        'url': Uri.parse(
          provider.hls1080 ?? provider.hls480 ?? provider.hls720 ?? '',
        ),
      });
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

  void _handleDoubleTap(double xPosition, VideoControllerProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (xPosition < screenWidth / 2) {
      provider.seekBackward();
      setState(() {
        _seekIcon = Icons.replay_10;
        _showSeekIcon = true;
      });
    } else {
      provider.seekForward();
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
    _displayTimer?.cancel();
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
          final l10n = AppLocalizations.of(context)!;

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
                              setState(() => _showControls = !_showControls);
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
                            child: IgnorePointer(
                              ignoring: !_showControls,
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black54,
                                      Colors.transparent,
                                    ],
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
                                      Row(
                                        children: [
                                          if (isPipAvailable)
                                            IconButton(
                                              onPressed:
                                                  () => _enablePip(provider),
                                              icon: const Icon(
                                                Icons.picture_in_picture,
                                                color: Colors.white,
                                              ),
                                            ),
                                          PopupMenuButton<String>(
                                            icon: const Icon(
                                              Icons.settings,
                                              color: Colors.white,
                                            ),
                                            onSelected: (String value) {
                                              switch (value) {
                                                case 'speed':
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (
                                                          context,
                                                        ) => AlertDialog(
                                                          title: Text(
                                                            l10n.select_playback_speed,
                                                          ),
                                                          content: SizedBox(
                                                            height: 300,
                                                            width:
                                                                double
                                                                    .maxFinite,
                                                            child: ListView.builder(
                                                              shrinkWrap: true,
                                                              itemCount:
                                                                  provider
                                                                      .playbackSpeeds
                                                                      .length,
                                                              itemBuilder:
                                                                  (
                                                                    context,
                                                                    index,
                                                                  ) => ListTile(
                                                                    title: Text(
                                                                      '${provider.playbackSpeeds[index]}x',
                                                                    ),
                                                                    onTap: () {
                                                                      provider
                                                                          .controller
                                                                          ?.setPlaybackSpeed(
                                                                            provider.playbackSpeeds[index],
                                                                          );
                                                                      Navigator.pop(
                                                                        context,
                                                                      );
                                                                    },
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                  );
                                                  break;
                                                case 'quality':
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (
                                                          context,
                                                        ) => AlertDialog(
                                                          title: Text(
                                                            l10n.quality,
                                                          ),
                                                          content: SizedBox(
                                                            height: 150,
                                                            width:
                                                                double
                                                                    .maxFinite,
                                                            child: ListView.builder(
                                                              shrinkWrap: true,
                                                              itemCount:
                                                                  provider
                                                                      .qualities
                                                                      .length,
                                                              itemBuilder:
                                                                  (
                                                                    context,
                                                                    index,
                                                                  ) => ListTile(
                                                                    title: Text(
                                                                      '${provider.qualities[index]}p',
                                                                    ),
                                                                    onTap: () {
                                                                      provider.changeQuality(
                                                                        provider
                                                                            .qualities[index],
                                                                      );
                                                                      Navigator.pop(
                                                                        context,
                                                                      );
                                                                    },
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                  );
                                                  break;
                                                default:
                                                  break;
                                              }
                                            },
                                            itemBuilder:
                                                (
                                                  BuildContext context,
                                                ) => <PopupMenuEntry<String>>[
                                                  PopupMenuItem<String>(
                                                    value: 'speed',
                                                    child: Text(
                                                      l10n.playback_speed,
                                                    ),
                                                  ),
                                                  PopupMenuItem<String>(
                                                    value: 'quality',
                                                    child: Text(l10n.quality),
                                                  ),
                                                ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 24,
                          left: 16,
                          right: 16,
                          child: PlayerControls(
                            provider: provider,
                            isFullscreen: true,
                            showControls: _showControls,
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
                                      provider.seekBackward();
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
                                      provider.seekForward();
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
