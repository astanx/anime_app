import 'package:anime_app/core/constants.dart';
import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/provider/video_controller_provider.dart';
import 'package:anime_app/ui/anime/widgets/fullscreen_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class AnimeScreen extends StatelessWidget {
  const AnimeScreen({super.key});
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
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final Anime anime = arguments['anime'] as Anime;
    final int? episodeIndex = arguments['episodeIndex'] as int?;

    final theme = Theme.of(context);

    return ChangeNotifierProvider(
      create: (context) {
        final provider = VideoControllerProvider();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          provider.loadEpisode(anime, episodeIndex ?? 0, context);
        });
        return provider;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(anime.release.names.main)),
        body: SafeArea(
          child: Consumer<VideoControllerProvider>(
            builder: (context, provider, _) {
              return _buildBody(context, provider, anime, theme);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    VideoControllerProvider provider,
    Anime anime,
    ThemeData theme,
  ) {
    final controller = provider.controller;
    final position = controller?.value.position ?? Duration.zero;
    final duration = controller?.value.duration ?? Duration.zero;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: theme.cardTheme.color,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Image.network(
                  '$baseUrl${anime.release.poster.optimized.src}',
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
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    anime.release.description,
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  anime.episodes[provider.episodeIndex].name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                if (controller?.value.isInitialized ?? false)
                  AspectRatio(
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
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.replay_10,
                                        color: Colors.white,
                                      ),
                                      onPressed:
                                          () => provider.seek(
                                            position - Duration(seconds: 10),
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
                                            position + Duration(seconds: 10),
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
                                                  ),
                                            ),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                value: position.inSeconds.toDouble(),
                                min: 0,
                                max: duration.inSeconds.toDouble(),
                                onChanged:
                                    (value) => provider.seek(
                                      Duration(seconds: value.toInt()),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (provider.episodeIndex > 0)
                      SizedBox(
                        width: 150,
                        height: 50,
                        child: InkWell(
                          onTap:
                              () => provider.loadEpisode(
                                anime,
                                provider.episodeIndex - 1,
                                context,
                              ),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(Icons.skip_previous),
                                Flexible(
                                  child: Text(
                                    anime
                                        .episodes[provider.episodeIndex - 1]
                                        .name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 150, height: 50),
                    if (provider.episodeIndex < anime.episodes.length - 1)
                      SizedBox(
                        width: 150,
                        height: 50,
                        child: InkWell(
                          onTap:
                              () => provider.loadEpisode(
                                anime,
                                provider.episodeIndex + 1,
                                context,
                              ),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    anime
                                        .episodes[provider.episodeIndex + 1]
                                        .name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.skip_next),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 150, height: 50),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
