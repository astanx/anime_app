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
  late VideoPlayerController _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    assert(
      args != null && args is Anime,
      'No valid Anime provided in arguments',
    );
    anime = args as Anime;

    final videoUrl =
        anime.episodes.isNotEmpty ? Uri.parse(anime.episodes[0].hls1080) : null;

    if (videoUrl != null) {
      _controller = VideoPlayerController.networkUrl(videoUrl)
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(anime.release.names.main)),
      body: Padding(
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
                  height: 10,
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
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ),
                const SizedBox(height: 16),

                // Video Player
                if (_controller.value.isInitialized)
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                else
                  const Center(child: CircularProgressIndicator()),

                // Play/Pause Button
                if (_controller.value.isInitialized)
                  IconButton(
                    icon: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_controller.value.isPlaying) {
                          _controller.pause();
                        } else {
                          _controller.play();
                        }
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
