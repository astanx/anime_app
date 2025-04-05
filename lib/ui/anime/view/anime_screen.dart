import 'package:anime_app/data/models/anime.dart';
import 'package:chewie/chewie.dart';
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
  ChewieController? _chewieController;

  List<DropdownMenuEntry<int>> get animeEpisodes => List.unmodifiable(
    List.generate(
      anime.episodes.length,
      (index) => DropdownMenuEntry(value: index, label: 'Episode ${index + 1}'),
    ),
  );

  var episodeIndex = 0;
  var fullscreen = false;

  Future<void> loadEpisode(int index) async {
    final episode = anime.episodes[index];
    final videoUrl = Uri.parse(
      episode.hls1080.isNotEmpty ? episode.hls1080 : episode.hls720,
    );

    await _controller?.dispose();

    _controller = VideoPlayerController.networkUrl(videoUrl);

      await _controller!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _controller!,
        allowFullScreen: true,
        allowMuting: true,
      );

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
    _chewieController?.dispose();
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
                    _chewieController == null
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : SizedBox(
                            height: 200,
                            child: Chewie(controller: _chewieController!),
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
