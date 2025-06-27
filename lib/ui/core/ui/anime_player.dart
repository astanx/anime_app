import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/kodik_result.dart';
import 'package:anime_app/data/provider/video_controller_provider.dart';
import 'package:anime_app/l10n/app_localizations.dart';
import 'package:anime_app/ui/core/ui/fullscreen_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class AnimePlayer extends StatelessWidget {
  final Anime anime;
  final KodikResult? kodikResult;

  const AnimePlayer({
    super.key,
    required this.anime,
    required this.kodikResult,
  });

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return hours > 0
        ? '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}'
        : '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoControllerProvider>(
      builder: (context, provider, _) {
        final controller = provider.controller;
        final position = controller?.value.position ?? Duration.zero;
        final duration = controller?.value.duration ?? Duration.zero;
        final episodeIndex = provider.episodeIndex;
        final l10n = AppLocalizations.of(context);

        if (!(controller?.value.isInitialized ?? false)) {
          return const Center(child: CircularProgressIndicator());
        }

        return AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.replay_10,
                              color: Colors.white,
                            ),
                            onPressed:
                                () => provider.seek(
                                  position - const Duration(seconds: 10),
                                ),
                          ),
                          IconButton(
                            icon: Icon(
                              controller.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            onPressed: provider.togglePlayPause,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.forward_10,
                              color: Colors.white,
                            ),
                            onPressed:
                                () => provider.seek(
                                  position + const Duration(seconds: 10),
                                ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.fullscreen,
                              color: Colors.white,
                            ),
                            onPressed:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => FullscreenPlayer(
                                          provider: provider,
                                          anime: anime,
                                          kodikResult: kodikResult,
                                        ),
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed:
                                  () => provider.seek(provider.openingEnd!),
                              child: Text(
                                l10n!.skip_opening,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 8,
                                ),
                              ),
                            )
                          else
                            const SizedBox.shrink(),
                          if (episodeIndex != null &&
                              (episodeIndex < anime.episodes.length - 1 &&
                                      position == duration ||
                                  ((provider.endingStart != null &&
                                      position >= provider.endingStart! &&
                                      position <=
                                          provider.endingStart! +
                                              const Duration(seconds: 20)))))
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
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed:
                                  duration ==
                                              (provider.endingEnd ??
                                                  Duration(seconds: 0)) ||
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
                                                Duration(seconds: 0)) ||
                                        duration == position
                                    ? l10n!.next_episode
                                    : l10n!.skip_ending,
                                style: TextStyle(color: Colors.black),
                              ),
                            )
                          else
                            const SizedBox.shrink(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatDuration(position),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Text(
                            formatDuration(duration),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Slider(
                      activeColor: Colors.white,
                      inactiveColor: Colors.grey[600],
                      value: position.inSeconds.toDouble().clamp(
                        0,
                        duration.inSeconds.toDouble(),
                      ),
                      min: 0,
                      max: duration.inSeconds.toDouble(),
                      onChanged:
                          (value) =>
                              provider.seek(Duration(seconds: value.toInt())),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
