import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/provider/video_controller_provider.dart';
import 'package:anime_app/ui/anime/widgets/fullscreen_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
                  anime.release.genres.map((g) => g.name).join(' • '),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
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
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        textStyle: const TextStyle(fontSize: 14),
                        dropdownMenuEntries: List.generate(
                          anime.episodes.length,
                          (index) => DropdownMenuEntry(
                            value: index,
                            label: 'Episode ${index + 1}',
                          ),
                        ),
                        initialSelection: provider.episodeIndex,
                        onSelected: (value) {
                          if (value != null && value != provider.episodeIndex) {
                            provider.loadEpisode(anime, value, context);
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      child: Center(
                        child: Text(
                          anime.episodes[provider.episodeIndex].name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
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
                                      fontWeight: FontWeight.w400,
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
                                      fontWeight: FontWeight.w400,
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
                ElevatedButton(
                  onPressed: () async {
                    final uri = Uri.parse(
                      'https://anilibria.top/api/v1/anime/torrents/${anime.torrents[0].id}/file',
                    );
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not launch URL')),
                      );
                    }
                  },
                  child: const Text('Download via Torrent'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
