import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:anime_app/core/utils/format_duration.dart';
import 'package:anime_app/data/provider/video_controller_provider.dart';
import 'package:anime_app/l10n/app_localizations.dart';

class PlayerControls extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final controller = provider.controller;
    final anime = provider.anime;
    final episodeIndex = provider.episodeIndex;

    if (controller == null ||
        !controller.value.isInitialized ||
        anime == null ||
        episodeIndex == null) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final duration = controller.value.duration;
    final isReversedTimer = provider.isReversedTimer;
    final isDragging = provider.isDragging;
    final desiredPosition = provider.desiredPosition;
    final position =
        isDragging
            ? Duration(seconds: desiredPosition.toInt())
            : controller.value.position;

    final isNearEnd = position >= duration - const Duration(seconds: 1);
    final inEndingRange =
        provider.endingStart != null &&
        position >= provider.endingStart! &&
        position <= provider.endingStart! + const Duration(seconds: 20);
    final isAccurateEnding =
        provider.endingEnd != null &&
        (duration - provider.endingEnd!).abs() < const Duration(seconds: 5);
    final isEnding =
        (episodeIndex < anime.previewEpisodes.length - 1 && isNearEnd) ||
        inEndingRange;

    String subtitleText = '';
    for (var cue in provider.subtitles) {
      if (position >= cue.startTime && position <= cue.endTime) {
        subtitleText = cue.text;
        break;
      }
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        IgnorePointer(
          ignoring: !showControls,
          child: AnimatedOpacity(
            opacity: showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (provider.openingStart != null &&
                          provider.openingEnd != null &&
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
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
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
                      if (isEnding &&
                          provider.endingEnd != null &&
                          provider.endingStart != null)
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
                          onPressed: () {
                            if (isAccurateEnding || isNearEnd) {
                              provider.seek(duration);
                              provider.loadEpisode(
                                anime,
                                episodeIndex + 1,
                                context,
                              );
                            } else {
                              provider.seek(
                                Duration(
                                  seconds:
                                      anime.episodes[episodeIndex].ending.end,
                                ),
                              );
                            }
                          },
                          child: Text(
                            isAccurateEnding || isNearEnd
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
                        onPressed: provider.reverseTimer,
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
                    provider.seek(Duration(seconds: value.toInt()));
                  },
                ),
              ],
            ),
          ),
        ),

        if (subtitleText.isNotEmpty)
          Positioned(
            bottom: showControls ? 60 : 20,
            left: 0,
            right: 0,
            child: Html(
              data: subtitleText,
              style: {
                'body': Style(
                  color: Colors.white,
                  fontSize: isFullscreen ? FontSize(18) : FontSize(14),
                  textAlign: TextAlign.center,
                  lineHeight: LineHeight(1.3),
                  textShadow: [
                    Shadow(
                      blurRadius: 4.0,
                      color: Colors.black,
                      offset: const Offset(1.0, 1.0),
                    ),
                  ],
                ),
              },
            ),
          ),
      ],
    );
  }
}
