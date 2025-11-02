import 'dart:async';
import 'dart:io';
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
    required this.isWide,
  });
  final VideoControllerProvider provider;
  final bool isWide;
  final Anime anime;

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
          final isWide = widget.isWide;
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
                                        icon: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: isWide ? 40 : 28,
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      Row(
                                        children: [
                                          if (isPipAvailable)
                                            IconButton(
                                              iconSize: isWide ? 40 : 28,
                                              onPressed:
                                                  () => _enablePip(provider),
                                              icon: const Icon(
                                                Icons.picture_in_picture,
                                                color: Colors.white,
                                              ),
                                            ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.settings,
                                              color: Colors.white,
                                              size: isWide ? 40 : 28,
                                            ),
                                            onPressed:
                                                () => _showSettingsBottomSheet(
                                                  context,
                                                  provider,
                                                  l10n,
                                                  isWide,
                                                ),
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
                            isWide: isWide,
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
                                    icon: Icon(
                                      Icons.replay_10,
                                      size: isWide ? 80 : 40,
                                    ),
                                    color: Colors.white,
                                    onPressed: () {
                                      provider.seekBackward();
                                      _startHideTimer();
                                    },
                                  ),
                                ),
                                SizedBox(width: isWide ? 128 : 48),
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
                                      size: isWide ? 88 : 44,
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
                                SizedBox(width: isWide ? 128 : 48),
                                IgnorePointer(
                                  ignoring: !_showControls,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.forward_10,
                                      size: isWide ? 80 : 40,
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

  void _showSettingsBottomSheet(
    BuildContext context,
    VideoControllerProvider provider,
    AppLocalizations l10n,
    bool isWide,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            expand: false,
            builder:
                (context, scrollController) => Container(
                  padding: EdgeInsets.all(isWide ? 24.0 : 16.0),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.speed,
                          color: Colors.white,
                          size: isWide ? 32 : 24,
                        ),
                        title: Text(
                          l10n.playback_speed,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isWide ? 24 : 18,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: Text(l10n.select_playback_speed),
                                  content: SizedBox(
                                    height: 300,
                                    width: double.maxFinite,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: provider.playbackSpeeds.length,
                                      itemBuilder:
                                          (context, index) => ListTile(
                                            title: Text(
                                              '${provider.playbackSpeeds[index]}x',
                                            ),
                                            onTap: () {
                                              provider.controller
                                                  ?.setPlaybackSpeed(
                                                    provider
                                                        .playbackSpeeds[index],
                                                  );
                                              Navigator.pop(context);
                                            },
                                          ),
                                    ),
                                  ),
                                ),
                          );
                        },
                      ),
                      if (provider.qualities.length != 1)
                        ListTile(
                          leading: Icon(
                            Icons.hd,
                            color: Colors.white,
                            size: isWide ? 32 : 24,
                          ),
                          title: Text(
                            l10n.quality,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isWide ? 24 : 18,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: Text(l10n.quality),
                                    content: SizedBox(
                                      height: 150,
                                      width: double.maxFinite,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: provider.qualities.length,
                                        itemBuilder:
                                            (context, index) => ListTile(
                                              title: Text(
                                                '${provider.qualities[index].startsWith('hls') ? provider.qualities[index].substring(3) : provider.qualities[index]}p',
                                              ),
                                              onTap: () {
                                                provider.changeQuality(
                                                  provider.qualities[index],
                                                );
                                                Navigator.pop(context);
                                              },
                                            ),
                                      ),
                                    ),
                                  ),
                            );
                          },
                        ),
                      if (provider.subtitlesLanguages.isNotEmpty)
                        ListTile(
                          leading: Icon(
                            Icons.subtitles,
                            color: Colors.white,
                            size: isWide ? 32 : 24,
                          ),
                          title: Text(
                            l10n.subtitles,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isWide ? 24 : 18,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: Text(l10n.subtitles),
                                    content: SizedBox(
                                      height: 350,
                                      width: double.maxFinite,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount:
                                            provider.subtitlesLanguages.length +
                                            1,
                                        itemBuilder: (context, index) {
                                          if (index == 0) {
                                            return ListTile(
                                              leading: Icon(
                                                Icons.visibility_off_outlined,
                                                color:
                                                    provider.currentLanguage ==
                                                            ''
                                                        ? Theme.of(
                                                          context,
                                                        ).colorScheme.primary
                                                        : null,
                                              ),
                                              title: Text(
                                                l10n.disable_subtitles,
                                                style: TextStyle(
                                                  color:
                                                      provider.currentLanguage ==
                                                              ''
                                                          ? Theme.of(
                                                            context,
                                                          ).colorScheme.primary
                                                          : null,
                                                ),
                                              ),
                                              onTap: () {
                                                provider.changeLanguage('');
                                                Navigator.pop(context);
                                              },
                                            );
                                          }
                                          final language = provider
                                              .subtitlesLanguages
                                              .elementAt(index - 1);
                                          return ListTile(
                                            title: Text(
                                              language,
                                              style: TextStyle(
                                                color:
                                                    provider.currentLanguage ==
                                                            language
                                                        ? Theme.of(
                                                          context,
                                                        ).colorScheme.primary
                                                        : null,
                                              ),
                                            ),
                                            onTap: () {
                                              provider.changeLanguage(language);
                                              Navigator.pop(context);
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
          ),
    );
  }
}
