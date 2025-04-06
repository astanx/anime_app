import 'package:flutter/services.dart';
import 'package:anime_app/data/models/anime.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AnimeScreen extends StatefulWidget {
  const AnimeScreen({super.key});
  final episodeNumber = 0;
  @override
  State<AnimeScreen> createState() => _AnimeScreenState();
}

class _AnimeScreenState extends State<AnimeScreen> {
  late final Anime anime;
  VideoPlayerController? _controller;
  List<DropdownMenuEntry<int>> get animeEpisodes => List.unmodifiable(
    List.generate(
      anime.episodes.length,
      (index) => DropdownMenuEntry(value: index, label: 'Episode ${index + 1}'),
    ),
  );

  var episodeIndex = 0;

  Future<void> loadEpisode(int index) async {
    final episode = anime.episodes[index];
    final videoUrl = Uri.parse(
      episode.hls1080.isNotEmpty ? episode.hls1080 : episode.hls720,
    );

    await _controller?.dispose();

    _controller = VideoPlayerController.networkUrl(videoUrl);
    await _controller!.initialize();

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
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 140,
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
                              bottom: 16,
                              left: 16,
                              right: 16,
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
                          ],
                        ),
                      )
                    else
                      const Center(child: CircularProgressIndicator()),
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

class FullscreenPlayer extends StatefulWidget {
  final VideoPlayerController controller;

  const FullscreenPlayer({super.key, required this.controller});

  @override
  State<FullscreenPlayer> createState() => _FullscreenPlayerState();
}

class _FullscreenPlayerState extends State<FullscreenPlayer> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.replay_10, color: Colors.white),
                  onPressed: () async {
                    final position = await controller.position;
                    if (position != null) {
                      controller.seekTo(position - Duration(seconds: 10));
                    }
                  },
                ),
                IconButton(
                  icon: Icon(
                    controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      controller.value.isPlaying
                          ? controller.pause()
                          : controller.play();
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.forward_10, color: Colors.white),
                  onPressed: () async {
                    final position = await controller.position;
                    if (position != null) {
                      controller.seekTo(position + Duration(seconds: 10));
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.fullscreen_exit, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
