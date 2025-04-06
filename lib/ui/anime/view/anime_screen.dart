import 'package:anime_app/ui/anime/widgets/fullscreen_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:anime_app/data/models/anime.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AnimeScreen extends StatefulWidget {
  const AnimeScreen({super.key});
  @override
  State<AnimeScreen> createState() => _AnimeScreenState();
}

class _AnimeScreenState extends State<AnimeScreen> {
  late final Anime anime;
  VideoPlayerController? _controller;
  var episodeIndex = 0;
  double _currentPosition = 0.0;

  List<DropdownMenuEntry<int>> get animeEpisodes => List.unmodifiable(
    List.generate(
      anime.episodes.length,
      (index) => DropdownMenuEntry(value: index, label: 'Episode ${index + 1}'),
    ),
  );

  Future<void> loadEpisode(int index) async {
    final episode = anime.episodes[index];
    final videoUrl = Uri.parse(
      episode.hls1080.isNotEmpty ? episode.hls1080 : episode.hls720,
    );

    await _controller?.dispose();
    _controller = VideoPlayerController.networkUrl(videoUrl);
    await _controller!.initialize();

    _controller!.addListener(() {
      if (_controller!.value.isInitialized) {
        setState(() {
          _currentPosition =
              _controller!.value.position.inMilliseconds.toDouble();
        });
      }
    });

    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    assert(
      args != null && args is Anime,
      'No valid Anime provided in arguments',
    );
    anime = args as Anime;

    loadEpisode(episodeIndex);
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(anime.release.names.main)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: theme.cardTheme.color,
              elevation: theme.cardTheme.elevation,
              shadowColor: theme.cardTheme.shadowColor,
              shape: theme.cardTheme.shape,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Image.network(
                      'https://anilibria.top${anime.release.poster.optimized.src}',
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      anime.release.names.main,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${anime.release.episodesTotal} episodes  ${anime.release.isOngoing ? '| Ongoing' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        anime.release.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 150,
                          child: DropdownMenu(
                            inputDecorationTheme: InputDecorationTheme(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ),
                            textStyle: TextStyle(fontSize: 14),
                            dropdownMenuEntries: animeEpisodes,
                            initialSelection: episodeIndex,
                            onSelected: (value) {
                              if (value != null && value != episodeIndex) {
                                episodeIndex = value;
                                loadEpisode(episodeIndex);
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          width: 140,
                          child: Center(
                            child: Text(
                              anime.episodes[episodeIndex].name,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_controller?.value.isInitialized ?? false)
                      AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            VideoPlayer(_controller!),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
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
                                        IconButton(
                                          icon: Icon(
                                            Icons.replay_10,
                                            color: Colors.white,
                                          ),
                                          onPressed: () async {
                                            final currentPosition =
                                                await _controller!.position;
                                            if (currentPosition != null) {
                                              _controller!.seekTo(
                                                currentPosition -
                                                    Duration(seconds: 10),
                                              );
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            _controller!.value.isPlaying
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _controller!.value.isPlaying
                                                  ? _controller!.pause()
                                                  : _controller!.play();
                                            });
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.forward_10,
                                            color: Colors.white,
                                          ),
                                          onPressed: () async {
                                            final currentPosition =
                                                await _controller!.position;
                                            if (currentPosition != null) {
                                              _controller!.seekTo(
                                                currentPosition +
                                                    Duration(seconds: 10),
                                              );
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.fullscreen,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (_) => FullscreenPlayer(
                                                      controller: _controller!,
                                                    ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),

                                  Slider(
                                    value: _currentPosition,
                                    min: 0.0,
                                    max:
                                        _controller!
                                            .value
                                            .duration
                                            .inMilliseconds
                                            .toDouble(),
                                    onChanged: (value) {
                                      setState(() {
                                        _currentPosition = value;
                                        _controller!.seekTo(
                                          Duration(milliseconds: value.toInt()),
                                        );
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const Center(child: CircularProgressIndicator()),

                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (episodeIndex > 0)
                          SizedBox(
                            width: 150,
                            height: 50,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    episodeIndex = episodeIndex - 1;
                                    loadEpisode(episodeIndex);
                                  });
                                },
                                icon: Icon(Icons.skip_previous),
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 150, height: 50),

                        if (episodeIndex < anime.episodes.length - 1)
                          SizedBox(
                            width: 150,
                            height: 50,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    anime.episodes[episodeIndex + 1].name,
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        episodeIndex = episodeIndex + 1;
                                        loadEpisode(episodeIndex);
                                      });
                                    },
                                    icon: Icon(Icons.skip_next),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 150, height: 50),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final uri = Uri.parse(
                          'https://anilibria.top/api/v1/anime/torrents/${anime.torrents[0].id}/file',
                        );
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.platformDefault,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Could not launch the URL')),
                          );
                        }
                      },
                      child: Text('Download via Torrent'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
