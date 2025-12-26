import 'package:anime_app/core/utils/is_same_language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:anime_app/core/utils/format_duration.dart';
import 'package:anime_app/data/provider/video_controller_provider.dart';
import 'package:anime_app/l10n/app_localizations.dart';
import 'package:translator/translator.dart';

class PlayerControls extends StatefulWidget {
  final VideoControllerProvider provider;
  final bool isFullscreen;
  final bool showControls;
  final bool isWide;

  const PlayerControls({
    super.key,
    required this.provider,
    required this.isWide,
    this.isFullscreen = false,
    this.showControls = true,
  });

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls> {
  bool isLoading = false;
  String subtitleText = '';
  String processedSubtitleText = '';
  Duration? currentCueStartTime;

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
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
    final isWide = widget.isWide;
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

    final activeCues =
        provider.subtitles.where((cue) {
          return position >= cue.startTime && position <= cue.endTime;
        }).toList();

    Duration? newCueStartTime =
        activeCues.isNotEmpty ? activeCues.last.startTime : null;

    if (activeCues.isNotEmpty &&
        (currentCueStartTime == null ||
            newCueStartTime != currentCueStartTime ||
            subtitleText.isEmpty)) {
      currentCueStartTime = newCueStartTime;

      int cueIndex = 0;
      processedSubtitleText = activeCues
          .map((cue) {
            final words = cue.text.split(' ');
            final wordTags = words
                .asMap()
                .entries
                .map((entry) {
                  final wordIdx = entry.key;
                  final word = entry.value;
                  return '<a href="word:$cueIndex:$wordIdx:$word">$word</a>';
                })
                .join(' ');
            cueIndex++;
            return wordTags;
          })
          .join('<br>');

      subtitleText = activeCues.map((c) => c.text).join(' ');
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        if (processedSubtitleText.isNotEmpty)
          Positioned(
            bottom: widget.showControls ? 60 : 20,
            left: 0,
            right: 0,
            child: Html(
              data: processedSubtitleText,
              style: {
                'body': Style(
                  color: Colors.white,
                  fontSize:
                      isWide
                          ? FontSize(24)
                          : widget.isFullscreen
                          ? FontSize(18)
                          : FontSize(14),
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
                'a': Style(
                  color: Colors.white,
                  textDecoration: TextDecoration.none,
                ),
              },
              onLinkTap: (url, attributes, element) async {
                if (provider.translationLanguage.isEmpty ||
                    isSameSubtitleLanguage(
                      provider.translationLanguage,
                      provider.currentLanguage ?? '',
                    )) {
                  return;
                }

                if (url != null && url.startsWith('word:')) {
                  final parts = url.split(':');
                  if (parts.length == 4) {
                    final int cueIdx = int.parse(parts[1]);
                    final int wordIdx = int.parse(parts[2]);
                    final String originalWord = parts[3];

                    if (cueIdx < activeCues.length) {
                      final targetCue = activeCues[cueIdx];
                      final words = targetCue.text.split(' ');

                      if (wordIdx < words.length &&
                          words[wordIdx] == originalWord) {
                        final translation = await _translate(
                          originalWord,
                          provider.translationLanguage,
                        );
                        if (!mounted) return;

                        words[wordIdx] = translation;

                        activeCues[cueIdx] = targetCue.copyWith(
                          text: words.join(' '),
                        );

                        setState(() {
                          int currentCueIndex = 0;
                          processedSubtitleText = activeCues
                              .map((cue) {
                                final cueWords = cue.text.split(' ');
                                final wordTags = cueWords
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                      final wIdx = entry.key;
                                      final w = entry.value;
                                      return '<a href="word:$currentCueIndex:$wIdx:$w">$w</a>';
                                    })
                                    .join(' ');
                                currentCueIndex++;
                                return wordTags;
                              })
                              .join('<br>');

                          subtitleText = activeCues
                              .map((c) => c.text)
                              .join(' ');
                        });
                      }
                    }
                  }
                }
              },
            ),
          ),
        Column(
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
                          provider.openingStart! + const Duration(seconds: 20))
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
                          fontSize:
                              isWide
                                  ? 24
                                  : widget.isFullscreen
                                  ? 16
                                  : 8,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  if (isEnding)
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
                      onPressed: () async {
                        if ((isAccurateEnding || isNearEnd) &&
                            episodeIndex + 1 <
                                (provider.anime?.previewEpisodes.length ?? 0)) {
                          if (isLoading) return;
                          setState(() => isLoading = true);
                          provider.seek(duration);
                          await provider.loadEpisode(
                            anime,
                            episodeIndex + 1,
                            context,
                          );
                          setState(() => isLoading = false);
                        } else {
                          provider.seek(
                            Duration(
                              seconds:
                                  anime.episodes
                                      .firstWhere(
                                        (e) => e.id == provider.episodeID,
                                      )
                                      .ending
                                      .end,
                            ),
                          );
                        }
                      },
                      child: Text(
                        (isAccurateEnding || isNearEnd) &&
                                episodeIndex + 1 <
                                    (provider.anime?.previewEpisodes.length ??
                                        0)
                            ? l10n.next_episode
                            : l10n.skip_ending,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize:
                              isWide
                                  ? 24
                                  : widget.isFullscreen
                                  ? 16
                                  : 8,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            IgnorePointer(
              ignoring: !widget.showControls,
              child: AnimatedOpacity(
                opacity: widget.showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatDuration(position),
                        style: TextStyle(
                          fontSize: isWide ? 24 : 10,
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
                          setState(() {});
                        },
                        child: Text(
                          isReversedTimer
                              ? '${position - duration < Duration.zero ? '-' : ''}${formatDuration(duration - position)}'
                              : formatDuration(duration),
                          style: TextStyle(
                            fontSize: isWide ? 24 : 10,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IgnorePointer(
              ignoring: !widget.showControls,
              child: AnimatedOpacity(
                opacity: widget.showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Slider(
                  activeColor: Colors.white,
                  inactiveColor: Colors.grey[600],
                  value: position.inSeconds.toDouble(),
                  min: 0,
                  max: duration.inSeconds.toDouble(),
                  onChanged: (value) {
                    provider.seek(Duration(seconds: value.toInt()));
                    setState(() {});
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<String> _translate(String word, String translateTo) async {
    final translator = GoogleTranslator();
    final translation = await translator.translate(word, to: translateTo);
    return translation.text;
  }
}
