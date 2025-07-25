import 'package:anime_app/core/utils/format_duration.dart';
import 'package:anime_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:anime_app/data/provider/video_controller_provider.dart';

class PlayerControls extends StatefulWidget {
  final VideoControllerProvider provider;
  final bool isFullscreen;
  final bool showControls;

  const PlayerControls({
    super.key,
    required this.provider,
    this.isFullscreen = false,
    this.showControls = true,
  });

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls> {
  @override
  Widget build(BuildContext context) {
    final controller = widget.provider.controller;
    final isFullscreen = widget.isFullscreen;
    final showControls = widget.showControls;
    final anime = widget.provider.anime;
    final episodeIndex = widget.provider.episodeIndex;
    final kodikResult = widget.provider.kodikResult;
    if (controller == null ||
        !controller.value.isInitialized ||
        anime == null ||
        episodeIndex == null) {
      return const SizedBox.shrink();
    }
    final provider = widget.provider;
    final l10n = AppLocalizations.of(context)!;

    final duration = controller.value.duration;
    final isReversedTimer = provider.isReversedTimer;
    final isDragging = provider.isDragging;
    final desiredPosition = provider.desiredPosition;
    final position =
        isDragging
            ? Duration(seconds: desiredPosition.toInt())
            : controller.value.position;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (provider.openingStart != null &&
                  position >= provider.openingStart! &&
                  position <=
                      provider.openingStart! + const Duration(seconds: 20))
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromARGB(179, 158, 158, 158),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    provider.updateIsDragging(true);
                    provider.updateDesiredPosition(
                      provider.openingEnd!.inSeconds.toDouble(),
                    );

                    provider.seek(provider.openingEnd!);
                  },
                  child: Text(
                    l10n.skip_opening,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: isFullscreen ? 16 : 8,
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
              if (episodeIndex < anime.episodes.length - 1 &&
                      position == duration ||
                  ((provider.endingStart != null &&
                      position >= provider.endingStart! &&
                      position <=
                          provider.endingStart! + const Duration(seconds: 20))))
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromARGB(179, 158, 158, 158),
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
                            provider.updateIsDragging(true);
                            provider.updateDesiredPosition(
                              anime.episodes[episodeIndex].duration.toDouble(),
                            );
                            provider.seek(
                              Duration(
                                seconds: anime.episodes[episodeIndex].duration,
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
                            provider.updateIsDragging(true);
                            provider.updateDesiredPosition(
                              anime.episodes[episodeIndex].ending!.stop!
                                  .toDouble(),
                            );

                            provider.seek(
                              Duration(
                                seconds:
                                    anime.episodes[episodeIndex].ending!.stop!,
                              ),
                            );
                          },
                  child: Text(
                    duration == (provider.endingEnd ?? Duration(seconds: 0)) ||
                            duration == position
                        ? l10n.next_episode
                        : l10n.skip_ending,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: isFullscreen ? 16 : 8,
                    ),
                  ),
                ),
            ],
          ),
        ),
        IgnorePointer(
          ignoring: !showControls,
          child: AnimatedOpacity(
            opacity: showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatDuration(position),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          provider.reverseTimer();
                        },
                        child: Text(
                          isReversedTimer
                              ? '${position - duration < Duration.zero ? '-' : ''}${formatDuration(duration - position)}'
                              : formatDuration(duration),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Slider(
                  activeColor: Colors.white,
                  inactiveColor: Colors.grey[600],
                  value: position.inSeconds.toDouble(),
                  min: 0,
                  max: duration.inSeconds.toDouble(),
                  onChanged: (value) {
                    provider.updateIsDragging(true);
                    provider.updateDesiredPosition(value);
                  },
                  onChangeEnd: (value) {
                    provider.seek(Duration(seconds: value.toInt()));
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
